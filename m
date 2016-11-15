Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id B831E6B0038
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 22:03:49 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f188so87193922pgc.1
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 19:03:49 -0800 (PST)
Received: from out0-147.mail.aliyun.com (out0-147.mail.aliyun.com. [140.205.0.147])
        by mx.google.com with ESMTP id g2si24667146pfj.214.2016.11.14.19.03.48
        for <linux-mm@kvack.org>;
        Mon, 14 Nov 2016 19:03:48 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20161114203448.24197-1-jeremy.lefaure@lse.epita.fr>
In-Reply-To: <20161114203448.24197-1-jeremy.lefaure@lse.epita.fr>
Subject: Re: [PATCH v3] mm, thp: propagation of conditional compilation in khugepaged.c
Date: Tue, 15 Nov 2016 11:03:45 +0800
Message-ID: <027801d23eec$e16d5b10$a4481130$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?'J=C3=A9r=C3=A9my_Lefaure'?= <jeremy.lefaure@lse.epita.fr>, 'Andrew Morton' <akpm@linux-foundation.org>, "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>
Cc: linux-mm@kvack.org

>=20
> Commit b46e756f5e47 ("thp: extract khugepaged from mm/huge_memory.c")
> moved code from huge_memory.c to khugepaged.c. Some of this code =
should
> be compiled only when CONFIG_SYSFS is enabled but the condition around
> this code was not moved into khugepaged.c. The result is a compilation
> error when CONFIG_SYSFS is disabled:
>=20
> mm/built-in.o: In function `khugepaged_defrag_store':
> khugepaged.c:(.text+0x2d095): undefined reference to
> `single_hugepage_flag_store'
> mm/built-in.o: In function `khugepaged_defrag_show':
> khugepaged.c:(.text+0x2d0ab): undefined reference to
> `single_hugepage_flag_show'
>=20
> This commit adds the #ifdef CONFIG_SYSFS around the code related to
> sysfs.
>=20
> Signed-off-by: J=C3=A9r=C3=A9my Lefaure <jeremy.lefaure@lse.epita.fr>

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
