Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 0D8F56B0093
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 00:57:45 -0500 (EST)
Subject: Re: [PATCH] mm: break circular include from linux/mmzone.h
From: li guang <lig.fnst@cn.fujitsu.com>
In-Reply-To: <alpine.DEB.2.02.1302042119370.31498@chino.kir.corp.google.com>
References: <1360037707-13935-1-git-send-email-lig.fnst@cn.fujitsu.com>
	 <alpine.DEB.2.02.1302042119370.31498@chino.kir.corp.google.com>
Date: Tue, 05 Feb 2013 13:56:36 +0800
Message-ID: <1360043796.4449.24.camel@liguang.fnst.cn.fujitsu.com>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

=E5=9C=A8 2013-02-04=E4=B8=80=E7=9A=84 21:20 -0800=EF=BC=8CDavid Rientjes=
=E5=86=99=E9=81=93=EF=BC=9A
> On Tue, 5 Feb 2013, liguang wrote:
>=20
> > linux/mmzone.h included linux/memory_hotplug.h,
> > and linux/memory_hotplug.h also included
> > linux/mmzone.h, so there's a bad cirlular.
> >=20
>=20
> And both of these are protected by _LINUX_MMZONE_H and=20
> __LINUX_MEMORY_HOTPLUG_H, respectively, so what's the problem?

obviously, It's a logical error,
and It has no more effect other than
combination of these 2 header files.
so, why don't we separate them?





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
