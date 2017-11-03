Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id DF14F6B0033
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 12:14:44 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id e123so3225310oig.14
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 09:14:44 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o21si3547755otc.44.2017.11.03.09.14.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Nov 2017 09:14:44 -0700 (PDT)
Date: Fri, 3 Nov 2017 12:14:43 -0400 (EDT)
From: =?utf-8?Q?Marc-Andr=C3=A9?= Lureau <marcandre.lureau@redhat.com>
Message-ID: <1675520780.35881890.1509725683143.JavaMail.zimbra@redhat.com>
In-Reply-To: <30bfff65-4cb9-a6b6-ab31-73d767a4b8ae@oracle.com>
References: <20171031184052.25253-1-marcandre.lureau@redhat.com> <20171031184052.25253-4-marcandre.lureau@redhat.com> <30bfff65-4cb9-a6b6-ab31-73d767a4b8ae@oracle.com>
Subject: Re: [PATCH 3/6] hugetlb: expose hugetlbfs_inode_info in header
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, hughd@google.com, nyc@holomorphy.com

Hi

----- Original Message -----
> On 10/31/2017 11:40 AM, Marc-Andr=C3=A9 Lureau wrote:
> > The following patch is going to access hugetlbfs_inode_info field from
> > mm/shmem.c.
>=20
> The code looks fine.  However, I would prefer something different for the
> commit message.  Perhaps something like:
>=20
> hugetlbfs inode information will need to be accessed by code in mm/shmem.=
c
> for file sealing operations.  Move inode information definition from .c
> file to header for needed access.

Ok, Does the patch get your Reviewed-by tag with that change?

thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
