Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 3CE2F6B004A
	for <linux-mm@kvack.org>; Tue, 20 Mar 2012 07:32:18 -0400 (EDT)
Received: by eeke53 with SMTP id e53so3897684eek.14
        for <linux-mm@kvack.org>; Tue, 20 Mar 2012 04:32:16 -0700 (PDT)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [RFC PATCH 1/6] kenrel.h: add ALIGN_OF_LAST_BIT()
References: <1332238884-6237-1-git-send-email-laijs@cn.fujitsu.com>
 <1332238884-6237-2-git-send-email-laijs@cn.fujitsu.com>
Date: Tue, 20 Mar 2012 12:32:14 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.wbgvn00x3l0zgt@mpn-glaptop>
In-Reply-To: <1332238884-6237-2-git-send-email-laijs@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <laijs@cn.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 20 Mar 2012 11:21:19 +0100, Lai Jiangshan <laijs@cn.fujitsu.com>=
 wrote:

> Get the biggest 2**y that x % (2**y) =3D=3D 0 for the align value.
>
> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
> ---
>  include/linux/kernel.h |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
>
> diff --git a/include/linux/kernel.h b/include/linux/kernel.h
> index 5113462..2c439dc 100644
> --- a/include/linux/kernel.h
> +++ b/include/linux/kernel.h
> @@ -44,6 +44,8 @@
>  #define PTR_ALIGN(p, a)		((typeof(p))ALIGN((unsigned long)(p), (a)))
>  #define IS_ALIGNED(x, a)		(((x) & ((typeof(x))(a) - 1)) =3D=3D 0)
>+#define ALIGN_OF_LAST_BIT(x)	((((x)^((x) - 1))>>1) + 1)

Wouldn't ALIGNMENT() be less confusing? After all, that's what this macr=
o is
calculating, right? Alignment of given address.

> +
>  #define ARRAY_SIZE(arr) (sizeof(arr) / sizeof((arr)[0]) + __must_be_a=
rray(arr))
> /*


-- =

Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz=
    (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
