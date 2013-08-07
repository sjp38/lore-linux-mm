Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id A24076B003D
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 22:10:25 -0400 (EDT)
Received: by mail-qe0-f43.google.com with SMTP id k5so689972qej.30
        for <linux-mm@kvack.org>; Tue, 06 Aug 2013 19:10:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130807000154.GA3507@z460>
References: <20130807000154.GA3507@z460>
Date: Tue, 6 Aug 2013 23:10:24 -0300
Message-ID: <CABk0prQj7DjQ0+oX59KL1vGqLw3NM9tQ9XfUFgoB0fS5ZesZ3Q@mail.gmail.com>
Subject: Re: [PATCH] mm: numa: fix NULL pointer dereference
From: Mauro Dreissig <mukadr@gmail.com>
Content-Type: multipart/alternative; boundary=047d7b6da3d26082a804e3520b33
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mauro D <mukadr@gmail.com>

--047d7b6da3d26082a804e3520b33
Content-Type: text/plain; charset=ISO-8859-1

2013/8/6 Mauro Dreissig <mukadr@gmail.com>

> From: Mauro Dreissig <mukadr@gmail.com>
>
> The "pol->mode" field is accessed even when no mempolicy
> is assigned to the "pol" variable.
>
> Signed-off-by: Mauro Dreissig <mukadr@gmail.com>
> ---
>  mm/mempolicy.c | 12 ++++++++----
>  1 file changed, 8 insertions(+), 4 deletions(-)
>
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 6b1d426..105fff0 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -127,12 +127,16 @@ static struct mempolicy *get_task_policy(struct
> task_struct *p)
>
>         if (!pol) {
>                 node = numa_node_id();
> -               if (node != NUMA_NO_NODE)
> +               if (node != NUMA_NO_NODE) {
>                         pol = &preferred_node_policy[node];
>
> -               /* preferred_node_policy is not initialised early in boot
> */
> -               if (!pol->mode)
> -                       pol = NULL;
> +                       /*
> +                        * preferred_node_policy is not initialised early
> +                        * in boot
> +                        */
> +                       if (!pol->mode)
> +                               pol = NULL;
> +               }
>         }
>
>         return pol;
> --
> 1.8.1.2
>
>
A patch about this issue already exist, please ignore my message.

http://marc.info/?l=linux-mm&m=137576205227365&w=2

--047d7b6da3d26082a804e3520b33
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>2013/8/6 Mauro Dreissig <span dir=3D"ltr">&lt;<a href=
=3D"mailto:mukadr@gmail.com" target=3D"_blank">mukadr@gmail.com</a>&gt;</sp=
an><br></div><div class=3D"gmail_extra"><div class=3D"gmail_quote"><blockqu=
ote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left-wid=
th:1px;border-left-color:rgb(204,204,204);border-left-style:solid;padding-l=
eft:1ex">
From: Mauro Dreissig &lt;<a href=3D"mailto:mukadr@gmail.com">mukadr@gmail.c=
om</a>&gt;<br>
<br>
The &quot;pol-&gt;mode&quot; field is accessed even when no mempolicy<br>
is assigned to the &quot;pol&quot; variable.<br>
<br>
Signed-off-by: Mauro Dreissig &lt;<a href=3D"mailto:mukadr@gmail.com">mukad=
r@gmail.com</a>&gt;<br>
---<br>
=A0mm/mempolicy.c | 12 ++++++++----<br>
=A01 file changed, 8 insertions(+), 4 deletions(-)<br>
<br>
diff --git a/mm/mempolicy.c b/mm/mempolicy.c<br>
index 6b1d426..105fff0 100644<br>
--- a/mm/mempolicy.c<br>
+++ b/mm/mempolicy.c<br>
@@ -127,12 +127,16 @@ static struct mempolicy *get_task_policy(struct task_=
struct *p)<br>
<br>
=A0 =A0 =A0 =A0 if (!pol) {<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 node =3D numa_node_id();<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (node !=3D NUMA_NO_NODE)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (node !=3D NUMA_NO_NODE) {<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pol =3D &amp;preferred_node=
_policy[node];<br>
<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* preferred_node_policy is not initialised e=
arly in boot */<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!pol-&gt;mode)<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pol =3D NULL;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* preferred_node_policy is=
 not initialised early<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* in boot<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!pol-&gt;mode)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pol =3D NULL;=
<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
=A0 =A0 =A0 =A0 }<br>
<br>
=A0 =A0 =A0 =A0 return pol;<br>
<span class=3D""><font color=3D"#888888">--<br>
1.8.1.2<br>
<br>
</font></span></blockquote></div><div><br></div><div>A patch about this iss=
ue already exist, please ignore my message.<br></div><div><div><br></div><d=
iv><a href=3D"http://marc.info/?l=3Dlinux-mm&amp;m=3D137576205227365&amp;w=
=3D2">http://marc.info/?l=3Dlinux-mm&amp;m=3D137576205227365&amp;w=3D2</a><=
/div>
</div><div><br></div></div></div>

--047d7b6da3d26082a804e3520b33--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
