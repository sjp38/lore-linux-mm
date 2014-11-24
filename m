Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id F314E6B00A0
	for <linux-mm@kvack.org>; Mon, 24 Nov 2014 05:21:24 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id bj1so9211669pad.23
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 02:21:24 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id sz3si20668514pab.188.2014.11.24.02.21.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 24 Nov 2014 02:21:23 -0800 (PST)
From: Jijiagang <jijiagang@hisilicon.com>
Subject: RE: UBIFS assert failed in ubifs_set_page_dirty at 1421
Date: Mon, 24 Nov 2014 10:20:59 +0000
Message-ID: <BE257DAADD2C0D439647A27133296657394A75F1@SZXEMA511-MBS.china.huawei.com>
References: <BE257DAADD2C0D439647A271332966573949EFEC@SZXEMA511-MBS.china.huawei.com>
 <1413805935.7906.225.camel@sauron.fi.intel.com>
 <C3050A4DBA34F345975765E43127F10F62CC5D9B@SZXEMA512-MBX.china.huawei.com>
 <1413810719.7906.268.camel@sauron.fi.intel.com>
 <545C2CEE.5020905@huawei.com> <20141120123011.GA9716@node.dhcp.inet.fi>
 <BE257DAADD2C0D439647A27133296657394A65A4@SZXEMA511-MBS.china.huawei.com>
 <20141124091024.GA1190@node.dhcp.inet.fi>
In-Reply-To: <20141124091024.GA1190@node.dhcp.inet.fi>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Hujianyang <hujianyang@huawei.com>, "dedekind1@gmail.com" <dedekind1@gmail.com>, Caizhiyong <caizhiyong@hisilicon.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Wanli (welly)" <welly.wan@hisilicon.com>, "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>, "adrian.hunter@intel.com" <adrian.hunter@intel.com>

Hi Kirill,
I test your patch, bus there's no dump_vma definition.
The log is here, hope it will be helpful.

 page:817fd7e0 count:3 mapcount:1 mapping:a318bb8c index:0x4
 page flags: 0xa19(locked|uptodate|dirty|arch_1|private)
 pte_write: 1
 page:81441a80 count:3 mapcount:1 mapping:a318bb8c index:0x5
 page flags: 0x209(locked|uptodate|arch_1)
 pte_write: 1
 UBIFS assert failed in ubifs_set_page_dirty at 1422 (pid 545)
 CPU: 2 PID: 545 Comm: kswapd0 Tainted: P           O 3.10.0_s40 #19
 [<8001d8a0>] (unwind_backtrace+0x0/0x108) from [<80019f44>] (show_stack+0x=
20/0x24)
 [<80019f44>] (show_stack+0x20/0x24) from [<80acfa18>] (dump_stack+0x24/0x2=
c)
 [<80acfa18>] (dump_stack+0x24/0x2c) from [<8029766c>] (ubifs_set_page_dirt=
y+0x54/0x5c)
 [<8029766c>] (ubifs_set_page_dirty+0x54/0x5c) from [<800cea60>] (set_page_=
dirty+0x50/0x78)
 [<800cea60>] (set_page_dirty+0x50/0x78) from [<800f4b10>] (try_to_unmap_on=
e+0x124/0x410)
 [<800f4b10>] (try_to_unmap_one+0x124/0x410) from [<800f4f84>] (try_to_unma=
p_file+0x9c/0x740)
 [<800f4f84>] (try_to_unmap_file+0x9c/0x740) from [<800f56b8>] (try_to_unma=
p+0x40/0x78)
 [<800f56b8>] (try_to_unmap+0x40/0x78) from [<800d6a04>] (shrink_page_list+=
0x23c/0x884)
 [<800d6a04>] (shrink_page_list+0x23c/0x884) from [<800d76c8>] (shrink_inac=
tive_list+0x21c/0x3c8)
 [<800d76c8>] (shrink_inactive_list+0x21c/0x3c8) from [<800d7c20>] (shrink_=
lruvec+0x3ac/0x524)
 [<800d7c20>] (shrink_lruvec+0x3ac/0x524) from [<800d8970>] (kswapd+0x854/0=
xdc0)
 [<800d8970>] (kswapd+0x854/0xdc0) from [<80051e28>] (kthread+0xc8/0xcc)
 [<80051e28>] (kthread+0xc8/0xcc) from [<80015198>] (ret_from_fork+0x14/0x2=
0)
 UBIFS assert failed in ubifs_release_budget at 567 (pid 6)
 CPU: 3 PID: 6 Comm: kworker/u8:0 Tainted: P           O 3.10.0_s40 #19

> -----Original Message-----
> From: Kirill A. Shutemov [mailto:kirill@shutemov.name]
> Sent: Monday, November 24, 2014 5:10 PM
> To: Jijiagang
> Cc: Hujianyang; dedekind1@gmail.com; Caizhiyong;
> linux-fsdevel@vger.kernel.org; linux-mm@kvack.org; Wanli (welly);
> linux-mtd@lists.infradead.org; adrian.hunter@intel.com
> Subject: Re: UBIFS assert failed in ubifs_set_page_dirty at 1421
>=20
> On Mon, Nov 24, 2014 at 02:59:51AM +0000, Jijiagang wrote:
> > Hi Kirill,
> >
> > I add dump_page(page) in function ubifs_set_page_dirty.
> > And get this log when ubifs assert fail. Is it helpful for this problem=
?
>=20
> Not really. It seems you called dump_page() after
> __set_page_dirty_nobuffers() in ubifs_set_page_dirty().
>=20
> Could you try something like patch below. It assumes ubifs to compiled in=
 (not
> module).
>=20
> diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c index b5b593c45270..7b4386=
dd174e
> 100644
> --- a/fs/ubifs/file.c
> +++ b/fs/ubifs/file.c
> @@ -1531,7 +1531,7 @@ out_unlock:
>         return err;
>  }
>=20
> -static const struct vm_operations_struct ubifs_file_vm_ops =3D {
> +const struct vm_operations_struct ubifs_file_vm_ops =3D {
>         .fault        =3D filemap_fault,
>         .map_pages =3D filemap_map_pages,
>         .page_mkwrite =3D ubifs_vm_page_mkwrite, diff --git a/mm/rmap.c
> b/mm/rmap.c index 19886fb2f13a..343c4571df68 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1171,8 +1171,15 @@ static int try_to_unmap_one(struct page *page,
> struct vm_area_struct *vma,
>         pteval =3D ptep_clear_flush(vma, address, pte);
>=20
>         /* Move the dirty bit to the physical page now the pte is gone. *=
/
> -       if (pte_dirty(pteval))
> +       if (pte_dirty(pteval)) {
> +               extern const struct vm_operations_struct
> ubifs_file_vm_ops;
> +               if (vma->vm_ops =3D=3D &ubifs_file_vm_ops) {
> +                       dump_vma(vma);
> +                       dump_page(page, __func__);
> +                       pr_emerg("pte_write: %d\n", pte_write(pteval));
> +               }
>                 set_page_dirty(page);
> +       }
>=20
>         /* Update high watermark before we lower rss */
>         update_hiwater_rss(mm);
> --
>  Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
