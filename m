Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D6D286B0005
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 14:49:20 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id m130so1344603wma.1
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 11:49:20 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y8sor3254402edk.17.2018.03.16.11.49.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Mar 2018 11:49:19 -0700 (PDT)
MIME-Version: 1.0
References: <20180316182512.118361-1-wvw@google.com>
In-Reply-To: <20180316182512.118361-1-wvw@google.com>
From: Wei Wang <wvw@google.com>
Date: Fri, 16 Mar 2018 18:49:08 +0000
Message-ID: <CAGXk5yoVMd9B=nvob7s=niCAQ9oHAX84eupF9Eet_dAk7WTStg@mail.gmail.com>
Subject: Re: [PATCH] mm: add config for readahead window
Content-Type: multipart/alternative; boundary="f403045c0ebed1714605678c101d"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wvw@google.com>
Cc: gregkh@linuxfoundation.org, Todd Poynor <toddpoynor@google.com>, Wei Wang <wei.vince.wang@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>, Ingo Molnar <mingo@kernel.org>, Sherry Cheung <SCheung@nvidia.com>, Oliver O'Halloran <oohall@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Huang Ying <ying.huang@intel.com>, Dennis Zhou <dennisz@fb.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--f403045c0ebed1714605678c101d
Content-Type: text/plain; charset="UTF-8"

Android devices boot time benefits by bigger readahead window setting from
init. This patch will make readahead window a config so early boot can
benefit by it as well.


On Fri, Mar 16, 2018 at 11:25 AM Wei Wang <wvw@google.com> wrote:

> From: Wei Wang <wvw@google.com>
>
> Change VM_MAX_READAHEAD value from the default 128KB to a configurable
> value. This will allow the readahead window to grow to a maximum size
> bigger than 128KB during boot, which could benefit to sequential read
> throughput and thus boot performance.
>
> Signed-off-by: Wei Wang <wvw@google.com>
> ---
>  include/linux/mm.h | 2 +-
>  mm/Kconfig         | 8 ++++++++
>  2 files changed, 9 insertions(+), 1 deletion(-)
>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index ad06d42adb1a..d7dc6125833e 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2291,7 +2291,7 @@ int __must_check write_one_page(struct page *page);
>  void task_dirty_inc(struct task_struct *tsk);
>
>  /* readahead.c */
> -#define VM_MAX_READAHEAD       128     /* kbytes */
> +#define VM_MAX_READAHEAD       CONFIG_VM_MAX_READAHEAD_KB
>  #define VM_MIN_READAHEAD       16      /* kbytes (includes current page)
> */
>
>  int force_page_cache_readahead(struct address_space *mapping, struct file
> *filp,
> diff --git a/mm/Kconfig b/mm/Kconfig
> index c782e8fb7235..da9ff543bdb9 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -760,3 +760,11 @@ config GUP_BENCHMARK
>           performance of get_user_pages_fast().
>
>           See tools/testing/selftests/vm/gup_benchmark.c
> +
> +config VM_MAX_READAHEAD_KB
> +       int "Default max readahead window size in Kilobytes"
> +       default 128
> +       help
> +         This sets the VM_MAX_READAHEAD value to allow the readahead
> window
> +         to grow to a maximum size of configured. Increasing this value
> will
> +         benefit sequential read throughput.
> --
> 2.16.2.804.g6dcf76e118-goog
>
>

--f403045c0ebed1714605678c101d
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><span style=3D"color:rgb(34,34,34);font-family:sans-serif;=
font-size:13px;font-style:normal;font-variant-ligatures:normal;font-variant=
-caps:normal;font-weight:400;letter-spacing:normal;text-align:start;text-in=
dent:0px;text-transform:none;white-space:normal;word-spacing:0px;background=
-color:rgb(255,255,255);text-decoration-style:initial;text-decoration-color=
:initial;float:none;display:inline">Android devices boot time benefits by b=
igger readahead window setting from init. This patch will make readahead wi=
ndow a config so early boot can benefit by it as well.</span><br></div><br>=
<br><div class=3D"gmail_quote"><div dir=3D"ltr">On Fri, Mar 16, 2018 at 11:=
25 AM Wei Wang &lt;<a href=3D"mailto:wvw@google.com">wvw@google.com</a>&gt;=
 wrote:<br></div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8=
ex;border-left:1px #ccc solid;padding-left:1ex">From: Wei Wang &lt;<a href=
=3D"mailto:wvw@google.com" target=3D"_blank">wvw@google.com</a>&gt;<br>
<br>
Change VM_MAX_READAHEAD value from the default 128KB to a configurable<br>
value. This will allow the readahead window to grow to a maximum size<br>
bigger than 128KB during boot, which could benefit to sequential read<br>
throughput and thus boot performance.<br>
<br>
Signed-off-by: Wei Wang &lt;<a href=3D"mailto:wvw@google.com" target=3D"_bl=
ank">wvw@google.com</a>&gt;<br>
---<br>
=C2=A0include/linux/mm.h | 2 +-<br>
=C2=A0mm/Kconfig=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| 8 ++++++++<br>
=C2=A02 files changed, 9 insertions(+), 1 deletion(-)<br>
<br>
diff --git a/include/linux/mm.h b/include/linux/mm.h<br>
index ad06d42adb1a..d7dc6125833e 100644<br>
--- a/include/linux/mm.h<br>
+++ b/include/linux/mm.h<br>
@@ -2291,7 +2291,7 @@ int __must_check write_one_page(struct page *page);<b=
r>
=C2=A0void task_dirty_inc(struct task_struct *tsk);<br>
<br>
=C2=A0/* readahead.c */<br>
-#define VM_MAX_READAHEAD=C2=A0 =C2=A0 =C2=A0 =C2=A0128=C2=A0 =C2=A0 =C2=A0=
/* kbytes */<br>
+#define VM_MAX_READAHEAD=C2=A0 =C2=A0 =C2=A0 =C2=A0CONFIG_VM_MAX_READAHEAD=
_KB<br>
=C2=A0#define VM_MIN_READAHEAD=C2=A0 =C2=A0 =C2=A0 =C2=A016=C2=A0 =C2=A0 =
=C2=A0 /* kbytes (includes current page) */<br>
<br>
=C2=A0int force_page_cache_readahead(struct address_space *mapping, struct =
file *filp,<br>
diff --git a/mm/Kconfig b/mm/Kconfig<br>
index c782e8fb7235..da9ff543bdb9 100644<br>
--- a/mm/Kconfig<br>
+++ b/mm/Kconfig<br>
@@ -760,3 +760,11 @@ config GUP_BENCHMARK<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 performance of get_user_pages_fast().<br=
>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 See tools/testing/selftests/vm/gup_bench=
mark.c<br>
+<br>
+config VM_MAX_READAHEAD_KB<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0int &quot;Default max readahead window size in =
Kilobytes&quot;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0default 128<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0help<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0This sets the VM_MAX_READAHEAD value to =
allow the readahead window<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0to grow to a maximum size of configured.=
 Increasing this value will<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0benefit sequential read throughput.<br>
--<br>
2.16.2.804.g6dcf76e118-goog<br>
<br>
</blockquote></div>

--f403045c0ebed1714605678c101d--
