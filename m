Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56101C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 00:39:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D4A9020874
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 00:39:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="IKqPzlkB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D4A9020874
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 431446B0005; Sun, 11 Aug 2019 20:39:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3E1A36B0006; Sun, 11 Aug 2019 20:39:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D0FD6B0007; Sun, 11 Aug 2019 20:39:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0137.hostedemail.com [216.40.44.137])
	by kanga.kvack.org (Postfix) with ESMTP id 0BD206B0005
	for <linux-mm@kvack.org>; Sun, 11 Aug 2019 20:39:38 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id A35C6282B
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 00:39:37 +0000 (UTC)
X-FDA: 75811917594.20.dirt00_36e6e519fe949
X-HE-Tag: dirt00_36e6e519fe949
X-Filterd-Recvd-Size: 3534
Received: from mail-ua1-f67.google.com (mail-ua1-f67.google.com [209.85.222.67])
	by imf11.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 00:39:37 +0000 (UTC)
Received: by mail-ua1-f67.google.com with SMTP id 34so1925849uar.8
        for <linux-mm@kvack.org>; Sun, 11 Aug 2019 17:39:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=6K0DvhL9RJkMUKWGy9bBRNsMSDRRIMczdHWxj2ZlOLY=;
        b=IKqPzlkBpTxY+A47jneyPgFuefY8XtvBtZMXnqH7VkTU2q0nJcG3iIRUuKxPVzsVSJ
         qaquyNCY/6XJ7D82HonO4EBmwolNEFZ0EKXfqOGLmnfrGtGIpfHMNqIlMKefsCRAFSqZ
         JoExbp3p4N4WfyaHmR6RVo8ExwftKr4w/E5HNtfOeBbT3xa+aoWI8ruwrdtCuWimPd7I
         V3y+2iKeKtWpb4vFKx67OmWGvsA4thlgxbOSxsJnlK/b/PEdRHBI7Ylo+rUgOPHJMOjh
         BmhzmtoZeu51qfUhDBUGVzA8g+COBbey3b1/Z7KDSww6AYJInUYcnDhyf5zz4TAnOhqH
         Un5Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=6K0DvhL9RJkMUKWGy9bBRNsMSDRRIMczdHWxj2ZlOLY=;
        b=HtHz6QrxCJ52Q8bQSqh1AOLDq345MvMacrSGOZEQzunJXaxkPBQeKMFrqPBdjqBdO4
         0Zmy3q2KdlMGJAWWrxdn0m+nXfiLjWmxt3v/+Nl5e8z+dVRI46u+ixifjYM1vaOsEZrI
         PUnZM7TqWBG58D7h8VTje8qpYxCqvsfKQIGNlGAN7W4zvFphmJ8xNdJ2lbVb8kQ0vCwN
         v7zMbxZNbhiv8bw1i5m1QMPA3kvN9NT3FxsDacA789z2egBsYh5RuvHukO/iNRHE2rvJ
         DpN5yiADlh9DyOtj9VZaIYiGSYdLMc8JftirmbM+FnRgUE51QvjeADP/STyVdlAid6c1
         bDvA==
X-Gm-Message-State: APjAAAVeRMUm0JAaqoEY7DQjKSwSw1Cgb9PzvAfJpP9KIaKUq6iusRYw
	PO4uSN7INl4AcnbseXWCMDofZnxf/O51E3lPhDSnBQ==
X-Google-Smtp-Source: APXvYqxvKmRyM1n6aAxPB7BHyG0ztTWG0OjK+dcEQcs9gVLd7ek1DWS6G6ppS8xScBCLvhhXvUQFgbNQHh9Vv1eg9D0=
X-Received: by 2002:ab0:7618:: with SMTP id o24mr18290583uap.39.1565570376227;
 Sun, 11 Aug 2019 17:39:36 -0700 (PDT)
MIME-Version: 1.0
References: <20190811184613.20463-1-urezki@gmail.com> <20190811184613.20463-3-urezki@gmail.com>
In-Reply-To: <20190811184613.20463-3-urezki@gmail.com>
From: Michel Lespinasse <walken@google.com>
Date: Sun, 11 Aug 2019 17:39:23 -0700
Message-ID: <CANN689Hh-Pr-3r9HD7w=FcNGfj_E7-9HVsHu3J9gZts_DYug8A@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm/vmalloc: use generated callback to populate subtree_max_size
To: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, 
	Roman Gushchin <guro@fb.com>, Hillf Danton <hdanton@sina.com>, Michal Hocko <mhocko@suse.com>, 
	Matthew Wilcox <willy@infradead.org>, 
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt <rostedt@goodmis.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Aug 11, 2019 at 11:46 AM Uladzislau Rezki (Sony)
<urezki@gmail.com> wrote:
> RB_DECLARE_CALLBACKS_MAX defines its own callback to update the
> augmented subtree information after a node is modified. It makes
> sense to use it instead of our own propagate implementation.
>
> Apart of that, in case of using generated callback we can eliminate
> compute_subtree_max_size() function and get rid of duplication.
>
> Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>

Reviewed-by: Michel Lespinasse <walken@google.com>

Love it. Thanks a lot for the cleanup!

