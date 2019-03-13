Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64B36C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 15:47:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2348920854
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 15:47:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2348920854
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7FCEF8E0004; Wed, 13 Mar 2019 11:47:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7AB0A8E0001; Wed, 13 Mar 2019 11:47:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 69A0F8E0004; Wed, 13 Mar 2019 11:47:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0FA3A8E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 11:47:15 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id p4so1135610edd.0
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 08:47:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=J+p2LYO7feD6XW0EZkueZAMT9ZK7thvtMViqoazXSC8=;
        b=Gb6SH6ztyhjLm5eyCJ6jFLgc7I6olrncU4OZpQ9Jy2XRbVcvPWHw7zZD0FdRUGIUS7
         Xdxnhs23LstAcszj1xoKnSjSDhcIBZC9ICSPTf01Qz76P3sQHR8PiWdJGHgnRuuch9l0
         SQnau3TwNp6umm5Z+ULDFo7cQe5hAIrMisjZvnsSx+bB2Cx+qGW1FAVk9F+/uKjNSvAh
         Ygf2kixLvd5Z5gK0d4fvch9MKibtZmocpmoSLyqFK/ZBxI3NTta7PkZ9i1g1fmSNVpf4
         KVn51ObV6hOcKIXWtiPdKP5QJ3A3vsPmejFpoX/YldXeDOgmjKlcCgqQF8fVdytI6oYu
         B8mQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAVuyaavMjg3Uxc7kvk0H3+0BvnJgKX4qqjrPKaJQnWfPyb2076j
	cLndYTBeQ3l2cHvvgerWhzxWDw0YeROsJDri5/TPOIIA61fJcLwrtpP3VGhGndFVp2NpirjpLJq
	A0JgXGUoA99KUYAXdY5x8Y0Y6XDjuYwNVNfXJpqI004c/ooONdRVHGbtDFzdOiV2LBg==
X-Received: by 2002:a17:906:5245:: with SMTP id y5mr10662555ejm.151.1552492034525;
        Wed, 13 Mar 2019 08:47:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz1W05D0yAZirPHS4vP2a0MQjxmcqkKDXwxCVuWYUUgoMvNRyBiAaeyZgpdgCBQRANrFvqR
X-Received: by 2002:a17:906:5245:: with SMTP id y5mr10662505ejm.151.1552492033594;
        Wed, 13 Mar 2019 08:47:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552492033; cv=none;
        d=google.com; s=arc-20160816;
        b=CwPQ5+NtcjAP9/cnS40LTFFWLACvMmbjUJsB1jXnfb6hJR8iTbFJaNMdh9mIHWHCKC
         GYwHotAtWfS/Te0hC/QkenQp/M97vHmADRJ8SzyRjee3PPYXPAEF/N5pTgXfeO72/4yy
         y7nvJSE9L2PCaX0GnqIfTjj2QB60DfLC7bZy142/z7p9+sTiX2jxk5oVUZCPYTIu0l5h
         wNazWBh5HgfyathMkkcgfaazAkvUExzU9jR7OVhSJXjXeQZ29kkXAO7wvWRehzl2ABT5
         lJgTE89SrixIayDnISsjgzphxTXQ3HWQuNv6fvk0GblsmVFU9ZoMtDWpd9Yx1t7DRIqU
         yO7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=J+p2LYO7feD6XW0EZkueZAMT9ZK7thvtMViqoazXSC8=;
        b=MhS7VZCTBqyuy8JyLKZxHLRs3jCTkoi9JhPkSaIkaxGCkNdFP+bHre67gO2RPopbRx
         Zu9a8fcJFOAEkxAUk2tG01Ro1oPbPEx+1MLWR+Rtu07jVJE+1I+9tB7/InuXw29+fuI7
         cBk2qazgJInCdtOZNIY4JLoGvwcjTig+2MsAKWvoyy2ZgevBaIgxYIgYVcQAgZQwZG6d
         mv5bq/mcnPWEf+va08X5JyL7OZCDtZrANEXyuSbnNvnwpZCOI6/rMxK37fNgtFbkUji4
         Rbm8wMnbGmyG0NF+Ka9cR6GwW9wmL2lEfh2nvu5pR+Ej0dLAEfCTd+yEt4X0exReCu3g
         CyQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d46si853836ede.307.2019.03.13.08.47.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 08:47:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 01D71B117;
	Wed, 13 Mar 2019 15:47:13 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 425C31E3FE8; Wed, 13 Mar 2019 16:47:12 +0100 (CET)
Date: Wed, 13 Mar 2019 16:47:12 +0100
From: Jan Kara <jack@suse.cz>
To: Kees Cook <keescook@chromium.org>
Cc: Jan Kara <jack@suse.cz>,
	syzbot <syzbot+2c49971e251e36216d1f@syzkaller.appspotmail.com>,
	Amir Goldstein <amir73il@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>, cai@lca.pw,
	Chris von Recklinghausen <crecklin@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>
Subject: Re: WARNING: bad usercopy in fanotify_read
Message-ID: <20190313154712.GJ9108@quack2.suse.cz>
References: <00000000000016f7d40583d79bd9@google.com>
 <CAGXu5jKjWwYk5N3mOH1A8fXX_0BT3r1At_3MzN9M+Ckg5irKXg@mail.gmail.com>
 <20190313143503.GD9108@quack2.suse.cz>
 <CAGXu5j+_Ao_CU8DG9nrTbx5ioDkJUFw0cGcLBMWnvNLe_eFJ4A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5j+_Ao_CU8DG9nrTbx5ioDkJUFw0cGcLBMWnvNLe_eFJ4A@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 13-03-19 08:35:33, Kees Cook wrote:
> On Wed, Mar 13, 2019 at 7:35 AM Jan Kara <jack@suse.cz> wrote:
> > On Tue 12-03-19 23:26:22, Kees Cook wrote:
> > > On Mon, Mar 11, 2019 at 1:42 PM syzbot
> > > <syzbot+2c49971e251e36216d1f@syzkaller.appspotmail.com> wrote:
> > > > C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=17ee410b200000
> > > > [...]
> > > > ------------[ cut here ]------------
> > > > Bad or missing usercopy whitelist? Kernel memory exposure attempt detected
> > > > from SLAB object 'fanotify_event' (offset 40, size 8)!
> > > > [...]
> > > >   copy_to_user include/linux/uaccess.h:151 [inline]
> > > >   copy_fid_to_user fs/notify/fanotify/fanotify_user.c:236 [inline]
> > > >   copy_event_to_user fs/notify/fanotify/fanotify_user.c:294 [inline]
> > >
> > > Looks like this is the fh/ext_fh union in struct fanotify_fid, field
> > > "fid" in struct fanotify_event. Given that "fid" is itself in a union
> > > against a struct path, I think instead of a whitelist using
> > > KMEM_CACHE_USERCOPY(), this should just use a bounce buffer to avoid
> > > leaving a whitelist open for path or ext_fh exposure.
> >
> > Do you mean to protect it from a situation when some other code (i.e. not
> > copy_fid_to_user()) would be tricked into copying ext_fh containing slab
> > pointer to userspace?
> 
> Yes. That's the design around the usercopy hardening. The
> "whitelisting" is either via code (with a bounce buffer, so only the
> specific "expected" code path can copy it), with a
> kmem_create_usercopy() range marking (generally best for areas that
> are not unions or when bounce buffers would be too big/slow), or with
> implicit whitelisting (via a constant copy size that cannot change at
> run-time, like: copy_to_user(dst, src, 6)).
> 
> In this case, since there are multiple unions in place and
> FANOTIFY_INLINE_FH_LEN is small, it seemed best to go with a bounce
> buffer.

OK, makes sense. I'll replace tha patch using kmem_create_usercopy() in my
tree with a variant you've suggested.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

