Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 7BF92900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 04:50:51 -0400 (EDT)
Received: by mail-qg0-f49.google.com with SMTP id e89so107520qgf.36
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 01:50:51 -0700 (PDT)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1bon0130.outbound.protection.outlook.com. [157.56.111.130])
        by mx.google.com with ESMTPS id u1si1306343qai.25.2014.10.28.01.50.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 28 Oct 2014 01:50:50 -0700 (PDT)
From: Dexuan Cui <decui@microsoft.com>
Subject: RE: Does slow_virt_to_phys() work with vmalloc() in the case of
 32bit-PAE and 2MB page?
Date: Tue, 28 Oct 2014 08:50:34 +0000
Message-ID: <F792CF86EFE20D4AB8064279AFBA51C610568754@HKNPRD3002MB017.064d.mgd.msft.net>
References: <F792CF86EFE20D4AB8064279AFBA51C610567A76@HKNPRD3002MB017.064d.mgd.msft.net>
In-Reply-To: <F792CF86EFE20D4AB8064279AFBA51C610567A76@HKNPRD3002MB017.064d.mgd.msft.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "dave.hansen@intel.com" <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, "H. Peter Anvin" <hpa@linux.intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

> -----Original Message-----
> From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org] On
> Behalf Of Dexuan Cui
> Sent: Tuesday, October 28, 2014 15:08 PM
> To: Dave Hansen; Rik van Riel; H. Peter Anvin
> Cc: linux-kernel@vger.kernel.org; linux-mm@kvack.org
> Subject: Does slow_virt_to_phys() work with vmalloc() in the case of 32bi=
t-
> PAE and 2MB page?
>=20
> Hi all,
> I suspect slow_virt_to_phys() may not work with vmalloc() in
> the 32-bit PAE case(when the pa > 4GB), probably due to 2MB page(?)
>=20
> Is there any known issue with slow_virt_to_phys() + vmalloc() +
> 32-bit PAE + 2MB page?
>=20
> From what I read the code of slow_virt_to_phys(), the variable 'psize' is
> assigned with a value but not used at all -- is this a bug?
After reading through the code, I think there is no issue here, though the
assignment of 'psize'  should be unnecessary, I think.
=20
Thanks,
-- Dexuan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
