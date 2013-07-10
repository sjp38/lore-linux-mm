Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 8A9606B0036
	for <linux-mm@kvack.org>; Wed, 10 Jul 2013 06:51:24 -0400 (EDT)
Subject: Re: [PATCH 3/4] PF: Provide additional direct page notification
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=iso-8859-1
From: Alexander Graf <agraf@suse.de>
In-Reply-To: <51DD3C2E.50409@de.ibm.com>
Date: Wed, 10 Jul 2013 12:51:18 +0200
Content-Transfer-Encoding: quoted-printable
Message-Id: <A58A4C11-C6B3-4B1A-B71D-3911B9A7AAF6@suse.de>
References: <1373378207-10451-1-git-send-email-dingel@linux.vnet.ibm.com> <1373378207-10451-4-git-send-email-dingel@linux.vnet.ibm.com> <51DC33E7.1030404@de.ibm.com> <282EB214-206B-4A04-9830-D97679C9F4EC@suse.de> <51DD3C2E.50409@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: Dominik Dingel <dingel@linux.vnet.ibm.com>, Gleb Natapov <gleb@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Xiantao Zhang <xiantao.zhang@intel.com>, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Ralf Baechle <ralf@linux-mips.org>, kvm@vger.kernel.org, linux-s390@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


On 10.07.2013, at 12:49, Christian Borntraeger wrote:

> On 10/07/13 12:39, Alexander Graf wrote:
>>=20
>> On 09.07.2013, at 18:01, Christian Borntraeger wrote:
>>=20
>>> On 09/07/13 15:56, Dominik Dingel wrote:
>>>> By setting a Kconfig option, the architecture can control when
>>>> guest notifications will be presented by the apf backend.
>>>> So there is the default batch mechanism, working as before, where =
the vcpu thread
>>>> should pull in this information. On the other hand there is now the =
direct
>>>> mechanism, this will directly push the information to the guest.
>>>>=20
>>>> Still the vcpu thread should call check_completion to cleanup =
leftovers,
>>>> that leaves most of the common code untouched.
>>>>=20
>>>> Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>
>>>=20
>>> Acked-by: Christian Borntraeger <borntraeger@de.ibm.com>=20
>>> for the "why". We want to use the existing architectured interface.
>>=20
>> Shouldn't this be a runtime option?
>=20
> This is an a) or b) depending on the architecture. So making this a =
kconfig
> option is the most sane approach no?

I guess I'm just missing the patch that actually selects it. Last thing =
I remember you can have a kernel configured for s390x that runs on any =
64bit capable system out there. What would you select? If that kernel =
runs on newer hardware, it would be able to do async pf, no?

There's a good chance I simply miss a critical component here :).


Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
