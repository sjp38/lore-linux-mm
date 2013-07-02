Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 847B66B0032
	for <linux-mm@kvack.org>; Tue,  2 Jul 2013 18:31:11 -0400 (EDT)
Subject: Re: [PATCH -V3 2/4] powerpc/kvm: Contiguous memory allocator based hash page table allocation
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
From: Alexander Graf <agraf@suse.de>
In-Reply-To: <1372804109.4122.25.camel@pasglop>
Date: Wed, 3 Jul 2013 00:31:05 +0200
Content-Transfer-Encoding: quoted-printable
Message-Id: <1ED23E51-19E6-4AA7-B241-937845877607@suse.de>
References: <1372743918-12293-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1372743918-12293-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <51D2EDD7.9060205@suse.de> <1372804109.4122.25.camel@pasglop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, paulus@samba.org, m.szyprowski@samsung.com, mina86@mina86.com, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, kvm@vger.kernel.org


On 03.07.2013, at 00:28, Benjamin Herrenschmidt wrote:

> On Tue, 2013-07-02 at 17:12 +0200, Alexander Graf wrote:
>> Is CMA a mandatory option in the kernel? Or can it be optionally=20
>> disabled? If it can be disabled, we should keep the preallocated=20
>> fallback case around for systems that have CMA disabled.
>=20
> Why ? More junk code to keep around ...
>=20
> If CMA is disabled, we can limit ourselves to dynamic allocation (with
> limitation to 16M hash table).

Aneesh adds a requirement for CMA on the KVM option in Kconfig, so all =
is well.


Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
