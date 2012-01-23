Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id B835E6B004D
	for <linux-mm@kvack.org>; Mon, 23 Jan 2012 05:15:20 -0500 (EST)
References: <1327310360.96918.YahooMailNeo@web162003.mail.bf1.yahoo.com>
Message-ID: <1327313719.76517.YahooMailNeo@web162002.mail.bf1.yahoo.com>
Date: Mon, 23 Jan 2012 02:15:19 -0800 (PST)
From: PINTU KUMAR <pintu_agarwal@yahoo.com>
Reply-To: PINTU KUMAR <pintu_agarwal@yahoo.com>
Subject: [Help] : RSS/PSS showing 0 during smaps for Xorg
In-Reply-To: <1327310360.96918.YahooMailNeo@web162003.mail.bf1.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Dear All,=0A=0AI am facing one problem for one of my kernel module for our =
linux mobile with kernel2.6.36.=0A=0AWhen I do cat /proc/<Xorg pid>/smaps |=
 grep -A 11 /dev/ump , to track information for my=A0ump module,=0Awe alway=
s get Rss/Pss as 0 kB as shown below:=0Acat /proc/1731/smaps | grep -A 11 /=
dev/ump=0A414db000-415ff000 rw-s 00015000 00:12 6803=A0=A0=A0=A0=A0=A0 /dev=
/ump=0ASize:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 1168 kB=0ARss:=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 0 kB=0APss:=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 0 kB=0Atrack_rss_value =3D 0, iswal=
kcalled =3D 1, smap_pte_range_called =3D 1,=A0swap_pte =3D 0,=A0not_pte_pre=
sent =3D 0,=A0not_normal_page =3D 1=0Aisspecial =3D 0, not_special =3D 1, i=
sMixedMap =3D 0, pfnpages_null =3D 0, pfnoff_flag =3D 0, not_cow_mapping =
=3D 1,=A0normal_page_end =3D 0=0A=A0=0AAfter tracing down the problem, I fo=
und out that during "show_smaps" in fs/proc/task_mmu.c and during call to s=
maps_pte_range the vm_normal_page() is always returning NULL for our /dev/u=
mp driver.=0A(smaps_pte_range() is the place where Rss/Pss information is p=
opulated)=0AThus mss->resident (Rss value) is never getting incremented.=A0=
 =0A=A0=0ATo trace the problem I added few flags during show_smaps & vm_nor=
mal_page() as shown above. The value of 1 indicates that the condition is e=
xecuted.=0AThus "normal_page_end" indicates that the "vm_normal_page" has n=
ever ended successfully and always returns from =0A"!is_cow_mapping()".=0A=
=A0=0ASo, I wanted to know the main cause for vm_normal_page() always retur=
ning NULL page for our ump driver. =0AWhat is that I am missing in my drive=
r ?=0A=A0=0ACan anyone please let me know what could be the problem in our =
driver.=0A=A0=0AThanks.=0A=A0=0AWith Regards,=0APintu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
