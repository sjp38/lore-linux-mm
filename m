Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11A5EC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 22:49:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CCBE120651
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 22:49:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CCBE120651
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 536086B0007; Wed, 27 Mar 2019 18:49:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E5196B0008; Wed, 27 Mar 2019 18:49:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3AF2D6B000A; Wed, 27 Mar 2019 18:49:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id DE9D96B0007
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 18:49:55 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id k8so4137513edl.22
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 15:49:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:reply-to:mail-followup-to:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=byamridhXhgadQeUbTvTURwoI+J5WIzPWwnNvEi5090=;
        b=qY35cMHfSAhF8pQV/DX/I+6YKjC62AWZU8J+o3I3TpffLg5r5GugmhvIarRvUuXOmp
         +uxSRPkFDjtIAw+BOUfoeFc+ZblL6HbFZAuH6DeZ+uNiuGea3TVFzHkHjgKym9UNlvyh
         kJHd/xnWAv2Lj4coTOY079/EDHQWeUV3Z9odDvxrQgk9OESyuXsDF1exJVDN7VqnAxFZ
         0GjrQZCgPGCzhNjT1yn4rHqLyY95OH8CYQEP+VuKVDGFfTRpEtoyq1CKjP58C3/LuRKd
         MmcHqq+j7rFTgeI8Iyg837ZFzv04WbG9Mi7A1tYSvhFSBs3HoMQYYfbunGk3PktxOWmW
         x2RA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dsterba@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=dsterba@suse.cz
X-Gm-Message-State: APjAAAVbxBKiQ4mC4TDYt28Ou0pbipL1ndR7O6BlcO0pC3hsrUxYaY3D
	LYtAKV2ngMDbt8uIP5rhyzWNoNhco5xV2aB2XkzVm+YC8bwYin8pycUbi4PKJSfFVdJlqt94ZSg
	MwKb2VMzy5fvqkb8eBu3TaxuiMdN3EgQAj2TdelIKbnomPecPePYBqogx1xepsVz0MQ==
X-Received: by 2002:a50:ca0d:: with SMTP id d13mr4985193edi.72.1553726995409;
        Wed, 27 Mar 2019 15:49:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzf+pP3tDHdyI061Un8srhr/PE74q9WmQyREdp0FO14uQoeUY/LRCKCym3EQgnOA8yKC4ro
X-Received: by 2002:a50:ca0d:: with SMTP id d13mr4985170edi.72.1553726994618;
        Wed, 27 Mar 2019 15:49:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553726994; cv=none;
        d=google.com; s=arc-20160816;
        b=y+TqQiKusA3s4j3w6tHYG6gdzUk0emujLm6APkDWNiFU5LqBCjfaCVPshFmp7LG/Cs
         hY8zWhCArZ0RZtIuDn1O1MH7aqZQKis3FGlaUhoELmb0WfRREvVET7Winq0U16wUf0h0
         I+vxvhcfLos+wYHCeoNx8/WUTUGKVPDHyxvHlnwyGR84/l2h1COAowtN7jLCJ1TcNoSR
         iFZc8UDvQnb8kPCYcCOfR4tYZSDWjjTP5Im0WJZw31lJ0mIiXR8sU5wsi0M49Jvxy3rN
         /UNc6Wy6mEoaJM6fGQqxxJrymueEkRslVobZ0GiLwwOW5+r48gb3uxYQZLEMW9w8WaFd
         1LDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :mail-followup-to:reply-to:message-id:subject:cc:to:from:date;
        bh=byamridhXhgadQeUbTvTURwoI+J5WIzPWwnNvEi5090=;
        b=XDLLLr6LJtFDNhAmBF4S8Pa/m2tQy33oaGsQB1o4uiycXHoF2Go2oO15MpGiqrR8h9
         B6+T5Tf/oCMaEYqkqR+BTUTLFAGbMOtK/5NRhJd4TgMpb5+ldjyNukscRiP83PeVwkMV
         nsZQ3GW+83MEb3MXEsj8HpwQrR0PitEZjKbnYhw6XkQFPe1Z+YWES0ckvLu+RcWmfsTR
         utZOgOtKKf3B5XOjN7m+2w7ZPhBPpOYnhXfibdnDD/FLpPCzy47BtsVxs2VbKeLjz3j6
         wsND9EbVFXlUQVWGZA/uGjOGQxAG6BCb7SRm/2eNweisJqTOl+jFDxnXoykQULjGixSE
         4hjg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dsterba@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=dsterba@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o4si2453085eda.121.2019.03.27.15.49.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 15:49:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of dsterba@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dsterba@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=dsterba@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 81AB7ACCD;
	Wed, 27 Mar 2019 22:49:53 +0000 (UTC)
Received: by ds.suse.cz (Postfix, from userid 10065)
	id 82603DA8D8; Wed, 27 Mar 2019 23:51:03 +0100 (CET)
Date: Wed, 27 Mar 2019 23:51:03 +0100
From: David Sterba <dsterba@suse.cz>
To: Matthew Wilcox <willy@infradead.org>
Cc: syzbot <syzbot+1145ec2e23165570c3ac@syzkaller.appspotmail.com>,
	akpm@linux-foundation.org, clm@fb.com, dan.carpenter@oracle.com,
	dave@stgolabs.net, dhowells@redhat.com, dsterba@suse.com,
	dvyukov@google.com, ebiederm@xmission.com, jbacik@fb.com,
	ktkhai@virtuozzo.com, ktsanaktsidis@zendesk.com,
	linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, manfred@colorfullife.com, mhocko@suse.com,
	nborisov@suse.com, penguin-kernel@I-love.SAKURA.ne.jp,
	rppt@linux.vnet.ibm.com, sfr@canb.auug.org.au, shakeelb@google.com,
	syzkaller-bugs@googlegroups.com, vdavydov.dev@gmail.com
Subject: Re: general protection fault in put_pid
Message-ID: <20190327225102.GB29086@twin.jikos.cz>
Reply-To: dsterba@suse.cz
Mail-Followup-To: dsterba@suse.cz, Matthew Wilcox <willy@infradead.org>,
	syzbot <syzbot+1145ec2e23165570c3ac@syzkaller.appspotmail.com>,
	akpm@linux-foundation.org, clm@fb.com, dan.carpenter@oracle.com,
	dave@stgolabs.net, dhowells@redhat.com, dsterba@suse.com,
	dvyukov@google.com, ebiederm@xmission.com, jbacik@fb.com,
	ktkhai@virtuozzo.com, ktsanaktsidis@zendesk.com,
	linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, manfred@colorfullife.com, mhocko@suse.com,
	nborisov@suse.com, penguin-kernel@I-love.SAKURA.ne.jp,
	rppt@linux.vnet.ibm.com, sfr@canb.auug.org.au, shakeelb@google.com,
	syzkaller-bugs@googlegroups.com, vdavydov.dev@gmail.com
References: <00000000000051ee78057cc4d98f@google.com>
 <000000000000c58fcf058519059e@google.com>
 <20190327202712.GT10344@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190327202712.GT10344@bombadil.infradead.org>
User-Agent: Mutt/1.5.23.1 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 27, 2019 at 01:27:12PM -0700, Matthew Wilcox wrote:
> On Wed, Mar 27, 2019 at 01:10:01PM -0700, syzbot wrote:
> > syzbot has bisected this bug to:
> > 
> > commit b9b8a41adeff5666b402996020b698504c927353
> > Author: Dan Carpenter <dan.carpenter@oracle.com>
> > Date:   Mon Aug 20 08:25:33 2018 +0000
> > 
> >     btrfs: use after free in btrfs_quota_enable
> 
> Not plausible.  Try again.

Agreed, grep for 'btrfs' in the console log does not show anything, ie.
no messages, slab caches nor functions on the stack.

