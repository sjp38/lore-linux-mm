Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 617C56B0034
	for <linux-mm@kvack.org>; Tue, 11 Jun 2013 18:50:35 -0400 (EDT)
Date: Tue, 11 Jun 2013 17:50:27 -0500
From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH -V7 09/18] powerpc: Switch 16GB and 16MB explicit
 hugepages to a different page table format
References: <87obbgpmk3.fsf@linux.vnet.ibm.com> <1370984023.18413.30@snotra>
In-Reply-To: <1370984023.18413.30@snotra> (from scottwood@freescale.com on
	Tue Jun 11 15:53:43 2013)
Message-ID: <1370991027.18413.33@snotra>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; delsp=Yes; format=Flowed
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Scott Wood <scottwood@freescale.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, paulus@samba.org, linuxppc-dev@lists.ozlabs.org, dwg@au1.ibm.com

On 06/11/2013 03:53:43 PM, Scott Wood wrote:
> On 06/08/2013 11:57:48 AM, Aneesh Kumar K.V wrote:
>> With the config shared I am not finding anything wrong, but I can't =20
>> test
>> these configs. Also can you confirm what you bisect this to
>>=20
>> e2b3d202d1dba8f3546ed28224ce485bc50010be
>> powerpc: Switch 16GB and 16MB explicit hugepages to a different page =20
>> table format
>=20
>>=20
>> or
>>=20
>> cf9427b85e90bb1ff90e2397ff419691d983c68b "powerpc: New hugepage =20
>> directory format"
>=20
> It's e2b3d202d1dba8f3546ed28224ce485bc50010be.
>=20
> It turned out to be the change from "pmd_none" to =20
> "pmd_none_or_clear_bad".  Making that change triggers the "bad pmd" =20
> messages even when applied to v3.9 -- so we had bad pmds all along, =20
> undetected.  Now I get to figure out why. :-(

So, for both pud and pgd we only call "or_clear_bad" when is_hugepd =20
returns false.  Why is it OK to do it unconditionally for pmd?

-Scott=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
