Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 0988B6B0070
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 10:45:55 -0500 (EST)
MIME-Version: 1.0
Message-ID: <05faaa76-24af-42a5-9619-a627e3411f1a@default>
Date: Tue, 13 Nov 2012 07:45:39 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 1/1] mm: Export a function to get vm committed memory
References: <<1352818957-9229-1-git-send-email-kys@microsoft.com>>
In-Reply-To: <<1352818957-9229-1-git-send-email-kys@microsoft.com>>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "K. Y. Srinivasan" <kys@microsoft.com>, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com, andi@firstfloor.org, akpm@linux-foundation.org, linux-mm@kvack.org, kamezawa.hiroyuki@gmail.com, mhocko@suse.cz, hannes@cmpxchg.org, yinghan@google.com, dan.magenheimer@oracle.com, konrad.wilk@oracle.com

> From: K. Y. Srinivasan [mailto:kys@microsoft.com]
> Sent: Tuesday, November 13, 2012 8:03 AM
> To: gregkh@linuxfoundation.org; linux-kernel@vger.kernel.org; devel@linux=
driverproject.org;
> olaf@aepfle.de; apw@canonical.com; andi@firstfloor.org; akpm@linux-founda=
tion.org; linux-mm@kvack.org;
> kamezawa.hiroyuki@gmail.com; mhocko@suse.cz; hannes@cmpxchg.org; yinghan@=
google.com;
> dan.magenheimer@oracle.com; konrad.wilk@oracle.com
> Cc: K. Y. Srinivasan
> Subject: [PATCH 1/1] mm: Export a function to get vm committed memory
>=20
> It will be useful to be able to access global memory commitment from devi=
ce
> drivers. On the Hyper-V platform, the host has a policy engine to balance
> the available physical memory amongst all competing virtual machines
> hosted on a given node. This policy engine is driven by a number of metri=
cs
> including the memory commitment reported by the guests. The balloon drive=
r
> for Linux on Hyper-V will use this function to retrieve guest memory comm=
itment.
> This function is also used in Xen self ballooning code.
>=20
> Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>

The patch to the Xen selfballoon driver is unnecessary, but is
one step in the direction of module support for this driver so
I am fine whether the patch is included here or not.

Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
