Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id F2C216B0005
	for <linux-mm@kvack.org>; Thu, 11 Aug 2016 00:12:43 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id pp5so103894063pac.3
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 21:12:43 -0700 (PDT)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id as4si961322pac.185.2016.08.10.21.12.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Aug 2016 21:12:43 -0700 (PDT)
Received: by mail-pa0-x244.google.com with SMTP id hh10so3960591pac.1
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 21:12:43 -0700 (PDT)
Subject: Re: [PATCH 1/4] dt-bindings: add doc for ibm,hotplug-aperture
References: <1470680843-28702-1-git-send-email-arbab@linux.vnet.ibm.com>
 <1470680843-28702-2-git-send-email-arbab@linux.vnet.ibm.com>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <92e34173-b2e2-bac0-3bbb-fc5407cbb8a5@gmail.com>
Date: Thu, 11 Aug 2016 14:12:31 +1000
MIME-Version: 1.0
In-Reply-To: <1470680843-28702-2-git-send-email-arbab@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>, Rob Herring <robh+dt@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Jonathan Corbet <corbet@lwn.net>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, devicetree@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Alistair Popple <apopple@au1.ibm.com>, Stewart Smith <stewart@linux.vnet.ibm.com>



On 09/08/16 04:27, Reza Arbab wrote:
> Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>
> ---
>  .../bindings/powerpc/opal/hotplug-aperture.txt     | 26 ++++++++++++++++++++++
>  1 file changed, 26 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/powerpc/opal/hotplug-aperture.txt
> 
> diff --git a/Documentation/devicetree/bindings/powerpc/opal/hotplug-aperture.txt b/Documentation/devicetree/bindings/powerpc/opal/hotplug-aperture.txt
> new file mode 100644
> index 0000000..b8dffaa
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/powerpc/opal/hotplug-aperture.txt
> @@ -0,0 +1,26 @@
> +Designated hotplug memory
> +-------------------------
> +
> +This binding describes a region of hotplug memory which is not present at boot,
> +allowing its eventual NUMA associativity to be prespecified.
> +
> +Required properties:
> +
> +- compatible
> +	"ibm,hotplug-aperture"
> +
> +- reg
> +	base address and size of the region (standard definition)
> +
> +- ibm,associativity
> +	NUMA associativity (standard definition)
> +
> +Example:
> +
> +A 2 GiB aperture at 0x100000000, to be part of nid 3 when hotplugged:
> +
> +	hotplug-memory@100000000 {
> +		compatible = "ibm,hotplug-aperture";
> +		reg = <0x0 0x100000000 0x0 0x80000000>;
> +		ibm,associativity = <0x4 0x0 0x0 0x0 0x3>;
> +	};
> 

+Stewart and Alistair

Looks good to me!

Acked-by: Balbir Singh <bsingharora@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
