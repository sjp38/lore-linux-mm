Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 46A6F6B0031
	for <linux-mm@kvack.org>; Mon, 30 Dec 2013 14:40:06 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id hz1so11906022pad.40
        for <linux-mm@kvack.org>; Mon, 30 Dec 2013 11:40:05 -0800 (PST)
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
        by mx.google.com with ESMTPS id s4si1784800pbg.303.2013.12.30.11.40.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 30 Dec 2013 11:40:04 -0800 (PST)
Received: by mail-pd0-f169.google.com with SMTP id v10so11616314pde.14
        for <linux-mm@kvack.org>; Mon, 30 Dec 2013 11:40:04 -0800 (PST)
References: <cover.1388409686.git.liwang@ubuntukylin.com> <52C1C6F7.8010809@intel.com>
Mime-Version: 1.0 (1.0)
In-Reply-To: <52C1C6F7.8010809@intel.com>
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Message-Id: <FFE7C704-791E-4B73-9251-EFB9135AB254@dilger.ca>
From: Andreas Dilger <adilger@dilger.ca>
Subject: Re: [PATCH 0/3] Fadvise: Directory level page cache cleaning support
Date: Mon, 30 Dec 2013 12:40:05 -0700
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Li Wang <liwang@ubuntukylin.com>, Alexander Viro <viro@zeniv.linux.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, Zefan Li <lizefan@huawei.com>, Matthew Wilcox <matthew@wil.cx>

On Dec 30, 2013, at 12:18, Dave Hansen <dave.hansen@intel.com> wrote:
>=20
> Why is this necessary to do in the kernel?  Why not leave it to
> userspace to walk the filesystem(s)?

I would suspect that trying to do it in userspace would be quite bad. It wou=
ld require traversing the whole directory tree to issue cache flushed for ea=
ch subdirectory, but it doesn't know when to stop traversal. That would mean=
 the "cache flush" would turn into "cache pollute" and cause a lot of disk I=
O for subdirectories not in cache to begin with.=20

Cheers, Andreas=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
