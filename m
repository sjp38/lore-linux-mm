Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6DF596B0261
	for <linux-mm@kvack.org>; Thu, 11 Aug 2016 13:53:30 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 1so3093030wmz.2
        for <linux-mm@kvack.org>; Thu, 11 Aug 2016 10:53:30 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id x67si1086842wmx.110.2016.08.11.10.53.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Aug 2016 10:53:29 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u7BHnLUZ122965
	for <linux-mm@kvack.org>; Thu, 11 Aug 2016 13:53:27 -0400
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com [32.97.110.158])
	by mx0b-001b2d01.pphosted.com with ESMTP id 24ru300q8x-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 11 Aug 2016 13:53:27 -0400
Received: from localhost
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Thu, 11 Aug 2016 11:53:26 -0600
Date: Thu, 11 Aug 2016 12:53:11 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/4] dt-bindings: add doc for ibm,hotplug-aperture
References: <1470680843-28702-1-git-send-email-arbab@linux.vnet.ibm.com>
 <1470680843-28702-2-git-send-email-arbab@linux.vnet.ibm.com>
 <92e34173-b2e2-bac0-3bbb-fc5407cbb8a5@gmail.com>
 <874m6r2a2s.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <874m6r2a2s.fsf@linux.vnet.ibm.com>
Message-Id: <20160811175311.GD12039@arbab-laptop.austin.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stewart Smith <stewart@linux.vnet.ibm.com>
Cc: Balbir Singh <bsingharora@gmail.com>, Rob Herring <robh+dt@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Jonathan Corbet <corbet@lwn.net>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, devicetree@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alistair Popple <apopple@au1.ibm.com>

On Thu, Aug 11, 2016 at 02:39:23PM +1000, Stewart Smith wrote:
>Forgive me for being absent on the whole discussion here, but is this 
>an OPAL specific binding? If so, shouldn't the docs also appear in the
>skiboot tree?

Good question. I guess it's not necessarily OPAL-specific, even though 
OPAL may initially be the only implementor of the binding.

Would it be more appropriate to move the file up a directory, directly 
under Documentation/devicetree/bindings/powerpc? I hesitated at that 
because the binding is tied to "ibm,associativity".

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
