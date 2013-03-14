Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 2EF776B0038
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 16:51:27 -0400 (EDT)
Received: by mail-we0-f176.google.com with SMTP id s43so2487997wey.21
        for <linux-mm@kvack.org>; Thu, 14 Mar 2013 13:51:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <51422008.3020208@gmx.de>
References: <51422008.3020208@gmx.de>
Date: Thu, 14 Mar 2013 21:51:25 +0100
Message-ID: <CAFLxGvyzkSsUJQMefeB2PcVBykZNqCQe5k19k0MqyVr111848w@mail.gmail.com>
Subject: Re: SLAB + UML : WARNING: at mm/page_alloc.c:2386
From: richard -rw- weinberger <richard.weinberger@gmail.com>
Content-Type: multipart/mixed; boundary=089e013c68489dc23804d7e8aff1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-1?Q?Toralf_F=F6rster?= <toralf.foerster@gmx.de>
Cc: linux-mm@kvack.org, user-mode-linux-user@lists.sourceforge.net, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>

--089e013c68489dc23804d7e8aff1
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On Thu, Mar 14, 2013 at 8:07 PM, Toralf F=F6rster <toralf.foerster@gmx.de> =
wrote:
> The following WARNING: can be triggered sometimes with trinity [1] under =
a user mode linux image
> using the SLUB allocator (and not with SLAB)
>
>
> 2013-03-14T19:09:51.071+01:00 trinity kernel: ------------[ cut here ]---=
---------
> 2013-03-14T19:09:51.071+01:00 trinity kernel: WARNING: at mm/page_alloc.c=
:2386 __alloc_pages_nodemask+0x153/0x750()
> 2013-03-14T19:09:51.071+01:00 trinity kernel: 3899fd14:  [<08342dd8>] dum=
p_stack+0x22/0x24
> 2013-03-14T19:09:51.071+01:00 trinity kernel: 3899fd2c:  [<0807d0da>] war=
n_slowpath_common+0x5a/0x80
> 2013-03-14T19:09:51.071+01:00 trinity kernel: 3899fd54:  [<0807d1a3>] war=
n_slowpath_null+0x23/0x30
> 2013-03-14T19:09:51.071+01:00 trinity kernel: 3899fd64:  [<080d3213>] __a=
lloc_pages_nodemask+0x153/0x750
> 2013-03-14T19:09:51.071+01:00 trinity kernel: 3899fdf0:  [<080d3838>] __g=
et_free_pages+0x28/0x50
> 2013-03-14T19:09:51.071+01:00 trinity kernel: 3899fe08:  [<080fc48f>] __k=
malloc_track_caller+0x3f/0x180
> 2013-03-14T19:09:51.071+01:00 trinity kernel: 3899fe30:  [<080dec76>] mem=
dup_user+0x26/0x70
> 2013-03-14T19:09:51.071+01:00 trinity kernel: 3899fe4c:  [<080dee7e>] str=
ndup_user+0x3e/0x60
> 2013-03-14T19:09:51.076+01:00 trinity kernel: 3899fe68:  [<0811b440>] cop=
y_mount_string+0x30/0x50
> 2013-03-14T19:09:51.076+01:00 trinity kernel: 3899fe7c:  [<0811be0a>] sys=
_mount+0x1a/0xe0
> 2013-03-14T19:09:51.076+01:00 trinity kernel: 3899feac:  [<08062a92>] han=
dle_syscall+0x82/0xb0
> 2013-03-14T19:09:51.076+01:00 trinity kernel: 3899fef4:  [<08074e7d>] use=
rspace+0x46d/0x590
> 2013-03-14T19:09:51.076+01:00 trinity kernel: 3899ffec:  [<0805f7cc>] for=
k_handler+0x6c/0x70
> 2013-03-14T19:09:51.076+01:00 trinity kernel: 3899fffc:  [<5a5a5a5a>] 0x5=
a5a5a5a
> 2013-03-14T19:09:51.076+01:00 trinity kernel:
> 2013-03-14T19:09:51.076+01:00 trinity kernel: ---[ end trace fd6f346f805e=
fdbe ]---
>
>
> for an UML guest (stable Gentoo x86) with kernel version 3.9-rc2-.... run=
ning at a host
> which is a stable x86 Gentoo with kernel 3.7.10
>
> The kernel config of the UML guest is attached.

Can you please re-run with the attached patch.
I'm wondering how much memory is requested.
>From reading the source I'd say it must be less than PAGE_SIZE.
But such a small allocation would not trigger the WARN_ON()...

--=20
Thanks,
//richard

--089e013c68489dc23804d7e8aff1
Content-Type: application/octet-stream; name="memdump_user.diff"
Content-Disposition: attachment; filename="memdump_user.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_heae7i8n1

ZGlmZiAtLWdpdCBhL21tL3V0aWwuYyBiL21tL3V0aWwuYwppbmRleCBhYjE0MjRkLi44NmU4ZTky
IDEwMDY0NAotLS0gYS9tbS91dGlsLmMKKysrIGIvbW0vdXRpbC5jCkBAIC04OSw2ICs4OSw4IEBA
IHZvaWQgKm1lbWR1cF91c2VyKGNvbnN0IHZvaWQgX191c2VyICpzcmMsIHNpemVfdCBsZW4pCiB7
CiAJdm9pZCAqcDsKIAorCXByaW50ayhLRVJOX0VSUiAibWVtZHVwX3VzZXI6ICVpXG4iLCBsZW4p
OworCiAJLyoKIAkgKiBBbHdheXMgdXNlIEdGUF9LRVJORUwsIHNpbmNlIGNvcHlfZnJvbV91c2Vy
KCkgY2FuIHNsZWVwIGFuZAogCSAqIGNhdXNlIHBhZ2VmYXVsdCwgd2hpY2ggbWFrZXMgaXQgcG9p
bnRsZXNzIHRvIHVzZSBHRlBfTk9GUwo=
--089e013c68489dc23804d7e8aff1--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
