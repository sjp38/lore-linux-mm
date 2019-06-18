Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD029C31E5B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 20:27:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D7AB20863
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 20:27:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D7AB20863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=zeniv.linux.org.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F2CC8E0006; Tue, 18 Jun 2019 16:27:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A3498E0001; Tue, 18 Jun 2019 16:27:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B9EF8E0006; Tue, 18 Jun 2019 16:27:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id C36D08E0001
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 16:27:29 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id r4so316193wrt.13
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 13:27:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent:sender;
        bh=9io0bp6KmQ5BOGi12+9IGNA86RrNOqaG7/eKxftayKg=;
        b=eHAJSArbmFtyzzC15AI4rvb2Uj/cb25Y/DJCAR8irUfV3WlsXkMG9247uIQQtVIo6f
         qBXqXRfT/gRDsYetI8gyC/URtUBfAUlJ23ef32K7QTNA0btd60XBc0lT7f5EP3BBw6dZ
         XbBPpnf3iH/v+0CXSLyzRcTFZuYzgKASF1Y//L7wolUBX+ANj5bh3vsrc+H8f7MxUftK
         9fBXrZWDXbDzLs1plTdKSob/iFdT4ISUuz0ECVR38hauq0L9foA0Z3OIcIds/f5F2llK
         ABtwBgUkGR5legCZEhAjj0ttLhDuzZRBScIcqFlmt2mA6q7sZWxHjtHGm2Eop36ksnl3
         WVng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
X-Gm-Message-State: APjAAAXNgEWh/FnnncPMSrMOXE77PgYw6lCN5xIT52DIW1pJjdrOQuAq
	bxHFfTMqM0K3jKrWpMtPtJlCkNcQZZsREXwl6VKnR+ADiaBQGqhyDnFeGAqrtX1loaol8dpdYg3
	dOsqmIL1wg/CeigPtdBTETXUjLYxOc6xT2GuJ/nv6tbqUZtMgcfir/Ak6qujYvNStZw==
X-Received: by 2002:a05:6000:4b:: with SMTP id k11mr4816104wrx.82.1560889649351;
        Tue, 18 Jun 2019 13:27:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxg06+NVwo/paSVTmUYvzTQdwQzR3OXKBZ1Fo7Qa+w6isYXDY1oASnv2rnD75dQ+Iw1nQUk
X-Received: by 2002:a05:6000:4b:: with SMTP id k11mr4816065wrx.82.1560889648533;
        Tue, 18 Jun 2019 13:27:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560889648; cv=none;
        d=google.com; s=arc-20160816;
        b=jx7PGj+AKEsjYrsfReHBee5xoFHpYzGV/FmjRpF3y4JaezLcIbmoYcCIONdSAlJRxk
         fsw1PSCbszTPNrHJyXMdfpymrO9wdqPkEsWGf7V7ffFWM+R4j6o3TfnbTEyCHs9HHI6h
         bWTmFb0j0vLavgapTEfk+oGC0eX1kqxza8gMrrta4vkF8sQq/xTQnLdV14AK/bpdT74r
         kqlN2DTpsFq5kvZXrwCMDfca0zpweUGvSlTY5vK/LII+9ybB30R3yWJrswZOxbu/3ZhI
         eiRUeg8bnLcdJKZ1SOLZDcIKaz2pjDHbeZADcAKk98QjIch5ATvRTcBlkKC7LhAmZefb
         5rrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:user-agent:in-reply-to:content-disposition:mime-version
         :references:message-id:subject:cc:to:from:date;
        bh=9io0bp6KmQ5BOGi12+9IGNA86RrNOqaG7/eKxftayKg=;
        b=hSrCahCgifkXLPGIRrXvwrCUBrtKl+kqgYngSRLCK7WWtBMrFqhi/esJtchuMaiFiC
         vsA0m+bzMxoZO/5LX6rCpNGi18KtUUfscuf3D3nJb4QbSgOlXWHDE1S4xQNFKGbFI5QX
         S6r5zQP7E658UMzmhYc1p1aJgkQWzHNmlPNYCxxbIuv3EAqtpHeLrTHDDqZmJibP7yFy
         Eml5xqjA8wq9K93rfOFOYtUz283oafkvDfmVLTegzSCPpUyIRt7Xa8RKUg3vNqRvZIgQ
         UdvewcjniFkWzNP+Dbb0BwhdLWLOAwTUafaKQuPYr/VbRQx0JGBpyY2ZxYkTUil2c6L0
         tRhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id n9si16396290wra.351.2019.06.18.13.27.28
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 18 Jun 2019 13:27:28 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) client-ip=195.92.253.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
Received: from viro by ZenIV.linux.org.uk with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hdKhN-0003PQ-66; Tue, 18 Jun 2019 20:27:21 +0000
Date: Tue, 18 Jun 2019 21:27:21 +0100
From: Al Viro <viro@zeniv.linux.org.uk>
To: Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Sami Tolvanen <samitolvanen@google.com>,
	Kees Cook <keescook@chromium.org>,
	Nick Desaulniers <ndesaulniers@google.com>,
	linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 3/4] jffs2: pass the correct prototype to read_cache_page
Message-ID: <20190618202721.GD17978@ZenIV.linux.org.uk>
References: <20190520055731.24538-1-hch@lst.de>
 <20190520055731.24538-4-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190520055731.24538-4-hch@lst.de>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 20, 2019 at 07:57:30AM +0200, Christoph Hellwig wrote:
> Fix the callback jffs2 passes to read_cache_page to actually have the
> proper type expected.  Casting around function pointers can easily
> hide typing bugs, and defeats control flow protection.

FWIW, this
unsigned char *jffs2_gc_fetch_page(struct jffs2_sb_info *c,
                                   struct jffs2_inode_info *f,
                                   unsigned long offset,
                                   unsigned long *priv)
{
        struct inode *inode = OFNI_EDONI_2SFFJ(f);
        struct page *pg;

        pg = read_cache_page(inode->i_mapping, offset >> PAGE_SHIFT,
                             (void *)jffs2_do_readpage_unlock, inode);
        if (IS_ERR(pg))
                return (void *)pg;

        *priv = (unsigned long)pg;
        return kmap(pg);
}
looks like crap.  And so does this:
void jffs2_gc_release_page(struct jffs2_sb_info *c,
                           unsigned char *ptr,
                           unsigned long *priv)
{
        struct page *pg = (void *)*priv;

        kunmap(pg);
        put_page(pg);
}

	First of all, there's only one caller for each of those, and both
are direct calls.  So passing struct page * around that way is ridiculous.
What's more, there is no reason not to do kmap() in caller (i.e. in
jffs2_garbage_collect_dnode()).  That way jffs2_gc_fetch_page() would
simply be return read_cache_page(....), and in the caller we'd have

        struct page *pg;
        unsigned char *pg_ptr;
...
        mutex_unlock(&f->sem);
        pg = jffs2_gc_fetch_page(c, f, start);
        if (IS_ERR(pg)) {
		mutex_lock(&f->sem);
                pr_warn("read_cache_page() returned error: %ld\n", PTR_ERR(pg));
                return PTR_ERR(pg);
        }
	pg_ptr = kmap(pg);
	mutex_lock(&f->sem);
...
	kunmap(pg);
	put_page(pg);

and that's it, preserving the current locking and with saner types...

