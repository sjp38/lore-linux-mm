Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5818BC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 03:45:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 20BB7206BA
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 03:45:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 20BB7206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kerneltoast.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC97B6B026D; Thu, 14 Mar 2019 23:45:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B789B6B026E; Thu, 14 Mar 2019 23:45:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A42716B026F; Thu, 14 Mar 2019 23:45:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6FE3D6B026D
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 23:45:08 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id v76so3419516oif.12
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 20:45:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=jqNqOSWwhyyf+mDbXl2RsLz9qA1Z9EB5hcTdEP6DIm8=;
        b=eon7w38bYmT1fZA+Tij4cp7qDfvunh0k0sBsnHGqk5wPqg8xBsNv6OtvaSyB/yXuu0
         F0CAGIEjMWxBILD0dSb439OlycNxYqduO+k6CetnqTJLMptjXA9kY4o9qy2QrSHrrEE1
         P3wAs21TGxX34guySDHXLAxMwV/4BGYqhHhZ9F0LK/hg+QHtsImxJXOHkhbExjUTeRAQ
         43vH62P36SWOrbrEfhZGLnyUfA0zgQercHM+X3zcVizM8PBKW4pr5f8im3l2fXQiEjwk
         Qc/riBZ3tEgDe2dwaYJUJr6F/x34nTSEd3o1uHiKbh0Z84jWngIbhLJEyqlLih5xaLiB
         fgrA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
X-Gm-Message-State: APjAAAVYBXaHNdmeWwertiIBcL28XxyWuoRnUxa4OVeggVrb3bN+/IZB
	Xs3bJq+hzykIcBhmG/lqcBa5okV0YfvKskVrUpJIEtLzAkVwXvaNQDxsg4nexDBZys7Ch/WTGg2
	CX3jNWXBqfJ4Ig5QUHlJBK0gO1LafJBLvmz2dal2QSD6rMFAiSGtQ9VKeyNfW8EI=
X-Received: by 2002:a05:6808:699:: with SMTP id k25mr324128oig.110.1552621508214;
        Thu, 14 Mar 2019 20:45:08 -0700 (PDT)
X-Received: by 2002:a05:6808:699:: with SMTP id k25mr324106oig.110.1552621507544;
        Thu, 14 Mar 2019 20:45:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552621507; cv=none;
        d=google.com; s=arc-20160816;
        b=GmMBR9kTWgVN0gBwvI3nj5Lr1n7lZGLvardzkO1I3p4s7W2vh1cTRDW87sZb6atXAG
         XBw77fTb6B7CLhKVnxib2oBCgAId2iEOs052xjm/WOUgwkBA1wQIhKfVWBhTIzteo7Ez
         Ot2L7a99qhuBziCuOQYcEnc5TnYncyI02EucfpkM4viGCLqPncynMCvCMMULpX0jemv3
         RhTFc0wR0OIXyJswUqSd/YU4jl2/ZcP+PAHb8mqdEHaE5oMkFWObhx9bsxkIw5py9khh
         OwDwlnmSXlvW2VAckoBSzWzg9cBrx/07vfh7FYvPi/eMoscnvxjbISOTdEKvP83em3wu
         woxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=jqNqOSWwhyyf+mDbXl2RsLz9qA1Z9EB5hcTdEP6DIm8=;
        b=ud3b9/q/T/97zrhn4ULzRnDb9TJCVCZwy60zdPBe+HQiUXLY21ucB+eL9lt2L83Kl8
         56cosrhb0UV9ZGPEUI/CrfcmUAXL4fQW8U9F46f8hfSOqWPYqL7Kz7dxh9ig4Bp7mUSs
         lTLstGXKWwC5kdMi2vliTFSAXinBhjbD2UJqKgvgKe06w6ldXhtzz+wZL+fzJHGHis7V
         rgHB43JhYdAmF38FoD9yQ0t7CwbvKtR7NDnt29MvhZpQKb1zWjRz1lRdMYuwwKyw/qqt
         UjvBhuc5fh75dUgMsURuZ84jtJdV5kMRv4JVbUv1tshi2dhCwg0srMI1Byl/Fk4lIVaz
         4Mig==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c76sor428775oig.156.2019.03.14.20.45.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Mar 2019 20:45:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
X-Google-Smtp-Source: APXvYqynQjzPuOsgLwmkCGsLMO/giFuMCJcqVPUnKs8zN8zfF6EmPqXnpAVPXz3B2yxsCH/0b2BTBw==
X-Received: by 2002:aca:47d4:: with SMTP id u203mr295513oia.175.1552621507233;
        Thu, 14 Mar 2019 20:45:07 -0700 (PDT)
Received: from sultan-box.localdomain ([107.193.118.89])
        by smtp.gmail.com with ESMTPSA id b2sm587690oih.1.2019.03.14.20.45.05
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 14 Mar 2019 20:45:06 -0700 (PDT)
Date: Thu, 14 Mar 2019 20:45:02 -0700
From: Sultan Alsawaf <sultan@kerneltoast.com>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Joel Fernandes <joel@joelfernandes.org>,
	Tim Murray <timmurray@google.com>, Michal Hocko <mhocko@kernel.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>,
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>,
	Christian Brauner <christian@brauner.io>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>,
	linux-mm <linux-mm@kvack.org>,
	kernel-team <kernel-team@android.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190315034502.GB3171@sultan-box.localdomain>
References: <20190311175800.GA5522@sultan-box.localdomain>
 <CAJuCfpHTjXejo+u--3MLZZj7kWQVbptyya4yp1GLE3hB=BBX7w@mail.gmail.com>
 <20190311204626.GA3119@sultan-box.localdomain>
 <CAJuCfpGpBxofTT-ANEEY+dFCSdwkQswox3s8Uk9Eq0BnK9i0iA@mail.gmail.com>
 <20190312080532.GE5721@dhcp22.suse.cz>
 <20190312163741.GA2762@sultan-box.localdomain>
 <CAEe=Sxn_uayj48wo7oqf8mNZ7QAGJUQVmkPcHcuEGjA_Z8ELeQ@mail.gmail.com>
 <CAEXW_YQMnbN+e-janGbZc5MH6MwdUdXNfonpLUu5O2nsSkJyeg@mail.gmail.com>
 <20190314204911.GA875@sultan-box.localdomain>
 <20190314231641.5a37932b@oasis.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190314231641.5a37932b@oasis.local.home>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 14, 2019 at 11:16:41PM -0400, Steven Rostedt wrote:
> How would you implement such a method in userspace? kill() doesn't take
> any parameters but the pid of the process you want to send a signal to,
> and the signal to send. This would require a new system call, and be
> quite a bit of work. If you can solve this with an ebpf program, I
> strongly suggest you do that instead.

This can be done by introducing a new signal number that provides SIGKILL
functionality while blocking (maybe SIGKILLBLOCK?).

Thanks,
Sultan

