Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7DE01C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 21:27:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 44F472070B
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 21:27:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 44F472070B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mit.edu
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC93B6B0006; Thu, 20 Jun 2019 17:27:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E79DC8E0002; Thu, 20 Jun 2019 17:27:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D8E788E0001; Thu, 20 Jun 2019 17:27:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id B86F56B0006
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 17:27:29 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id k31so5445864qte.13
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 14:27:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mail-followup-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=CYawPU6JjWvjE2T4iP4SlLl/rOVEe56dAhd/U+oP9s8=;
        b=sKHTgQBVztHhBFUjPoboRDWlzYUydSDf83kB7ZLFGWtE3+1qX+9cDsHNxNL7hlQK+O
         1Nw7XyaelD0QhmbjWcrP1FtfLB9vxjBwMbMvU1u3lKwvTHcXmzv4K+oUKEbT4lKeq1ZF
         6C6ffHXfvfQ08LJ2w5zPwtYbHk3EXNsGsAPRX7NECeF5v8t3hWCAAyFeQ27QqpAzJu0g
         Zvdk9xzi32MhGiCofJLRZNwYvItYNX91ptRBAOeTOd0Wwpik5Md3kYyA6qRBEC3ZDnTC
         sZQxe4lw0y8NrqBa2W5I8e8BE9NG/SwXl7edxAEaG9vIpZlCCCLCks12/0BdlwFa6a//
         KB+w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) smtp.mailfrom=tytso@mit.edu
X-Gm-Message-State: APjAAAW8xnuow8LzI6Y+FPgonN2vIEXM+idq2nWzaBF1H1iShLHB1394
	VRKmqBVRdLwS7ZJVR1oyjZWmnIxoJxj5iVTX1sNVzU21LJ1Bf/NQ0fklN5dQwvZjo8f5te1Lj2Y
	TN0uWHvW9+DvtVHnU12QY0BOyzYYa7p2MIV6fV/gVbB2SCIiiszlA70LdwfC+QW0uaA==
X-Received: by 2002:ac8:3932:: with SMTP id s47mr115367098qtb.264.1561066049559;
        Thu, 20 Jun 2019 14:27:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyFGbij0hBWIOts5RPeJT74bZPvdlt501eatPA3V3kWFAmFl5o/x9uJhcZPExCGOXts1xFh
X-Received: by 2002:ac8:3932:: with SMTP id s47mr115367074qtb.264.1561066049107;
        Thu, 20 Jun 2019 14:27:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561066049; cv=none;
        d=google.com; s=arc-20160816;
        b=Cb1pVrVGM+c9CrzZadpM2LfMU0/nSgdpk44C1MJbBlbX55p9PQzuHMew2WWpFosUjL
         Hm3LyWfhtzx5YUSczBcAAh3RvJx7MS2jaH2rEaAo6TQ/NXcolykVoOlogr7Q8Z79mg/B
         v3jP48y1RTdtNZ9DDKiWgyTPhWtRNU9JyolIunz9T6lup8iRdbr4PSDjKcSayXf6LjGk
         F+CecjvKzF0Yow/WHpyhfrgFg+P7ETNGMcv63Ayr/dbe0mked0mioDpfvR/GTLmMdvsm
         crzFdjDM6fgGHxR1J8d8afbazMcYu3RtjGypULkqGdBYujYUFPuPfMDgys6N3St3LuiJ
         wwBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :mail-followup-to:message-id:subject:cc:to:from:date;
        bh=CYawPU6JjWvjE2T4iP4SlLl/rOVEe56dAhd/U+oP9s8=;
        b=Rm6pGXv8im5r91K9CwEp6ihP6q1QsqVa7mhhSyoYxBznzL8zQiLiTB/suW/xhAdYLv
         L5zPMK1I80rBcDncd1GjcRAHik57AUvjWA0OENsD9ZfLdN/jXh3hC/rvdRIpes9pop1M
         B1WRg3I4Uw9EC5LYl+FDab1KUB89uXY4EHrSEL/nENIhvrkQlU6w9HEPEK8IfFHHp0rP
         dMXI+Kv1yuURsJTlNH+ZmtH8jFDEVl7kfiPv0SblXE6ZgxqMNRdJPwnGUccFcNF9yeMl
         7Ud0BnMkqi4J2d2KF6uKJFxHIfmbk6BfLjBD0eECvi8QosNNTFfIj1tqLoYjueJnri6/
         LM3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) smtp.mailfrom=tytso@mit.edu
Received: from outgoing.mit.edu (outgoing-auth-1.mit.edu. [18.9.28.11])
        by mx.google.com with ESMTPS id s40si607098qte.44.2019.06.20.14.27.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 14:27:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) client-ip=18.9.28.11;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) smtp.mailfrom=tytso@mit.edu
Received: from callcc.thunk.org (guestnat-104-133-0-109.corp.google.com [104.133.0.109] (may be forged))
	(authenticated bits=0)
        (User authenticated as tytso@ATHENA.MIT.EDU)
	by outgoing.mit.edu (8.14.7/8.12.4) with ESMTP id x5KLRR4u007652
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 20 Jun 2019 17:27:27 -0400
Received: by callcc.thunk.org (Postfix, from userid 15806)
	id DC7A0420484; Thu, 20 Jun 2019 17:27:26 -0400 (EDT)
Date: Thu, 20 Jun 2019 17:27:26 -0400
From: "Theodore Ts'o" <tytso@mit.edu>
To: Ross Zwisler <zwisler@chromium.org>
Cc: linux-kernel@vger.kernel.org, Ross Zwisler <zwisler@google.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>,
        linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-mm@kvack.org, Fletcher Woodruff <fletcherw@google.com>,
        Justin TerAvest <teravest@google.com>, Jan Kara <jack@suse.cz>,
        stable@vger.kernel.org
Subject: Re: [PATCH v2 3/3] ext4: use jbd2_inode dirty range scoping
Message-ID: <20190620212726.GD4650@mit.edu>
Mail-Followup-To: Theodore Ts'o <tytso@mit.edu>,
	Ross Zwisler <zwisler@chromium.org>, linux-kernel@vger.kernel.org,
	Ross Zwisler <zwisler@google.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>,
	linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org, Fletcher Woodruff <fletcherw@google.com>,
	Justin TerAvest <teravest@google.com>, Jan Kara <jack@suse.cz>,
	stable@vger.kernel.org
References: <20190620151839.195506-1-zwisler@google.com>
 <20190620151839.195506-4-zwisler@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190620151839.195506-4-zwisler@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 20, 2019 at 09:18:39AM -0600, Ross Zwisler wrote:
> Use the newly introduced jbd2_inode dirty range scoping to prevent us
> from waiting forever when trying to complete a journal transaction.
> 
> Signed-off-by: Ross Zwisler <zwisler@google.com>
> Reviewed-by: Jan Kara <jack@suse.cz>
> Cc: stable@vger.kernel.org

Applied, thanks.

					- Ted

