Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id B48746B0005
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 16:24:57 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id d65so158973418ith.0
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 13:24:57 -0700 (PDT)
Received: from mail-oi0-f67.google.com (mail-oi0-f67.google.com. [209.85.218.67])
        by mx.google.com with ESMTPS id c37si175795otd.58.2016.08.10.13.24.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Aug 2016 13:24:57 -0700 (PDT)
Received: by mail-oi0-f67.google.com with SMTP id t127so4800596oie.1
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 13:24:56 -0700 (PDT)
Date: Wed, 10 Aug 2016 15:24:55 -0500
From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH 1/4] dt-bindings: add doc for ibm,hotplug-aperture
Message-ID: <20160810202455.GA3468@rob-hp-laptop>
References: <1470680843-28702-1-git-send-email-arbab@linux.vnet.ibm.com>
 <1470680843-28702-2-git-send-email-arbab@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1470680843-28702-2-git-send-email-arbab@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Jonathan Corbet <corbet@lwn.net>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, devicetree@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Aug 08, 2016 at 01:27:20PM -0500, Reza Arbab wrote:
> Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>
> ---
>  .../bindings/powerpc/opal/hotplug-aperture.txt     | 26 ++++++++++++++++++++++
>  1 file changed, 26 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/powerpc/opal/hotplug-aperture.txt

Acked-by: Rob Herring <robh@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
