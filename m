Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 58BAF6B025F
	for <linux-mm@kvack.org>; Thu, 11 Aug 2016 00:39:39 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id o124so117077621pfg.1
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 21:39:39 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id c9si1096489pas.141.2016.08.10.21.39.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Aug 2016 21:39:38 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u7B4cnq1035935
	for <linux-mm@kvack.org>; Thu, 11 Aug 2016 00:39:37 -0400
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com [32.97.110.159])
	by mx0a-001b2d01.pphosted.com with ESMTP id 24r5ufkr6b-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 11 Aug 2016 00:39:37 -0400
Received: from localhost
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <stewart@linux.vnet.ibm.com>;
	Wed, 10 Aug 2016 22:39:37 -0600
From: Stewart Smith <stewart@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/4] dt-bindings: add doc for ibm,hotplug-aperture
In-Reply-To: <92e34173-b2e2-bac0-3bbb-fc5407cbb8a5@gmail.com>
References: <1470680843-28702-1-git-send-email-arbab@linux.vnet.ibm.com> <1470680843-28702-2-git-send-email-arbab@linux.vnet.ibm.com> <92e34173-b2e2-bac0-3bbb-fc5407cbb8a5@gmail.com>
Date: Thu, 11 Aug 2016 14:39:23 +1000
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <874m6r2a2s.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Rob Herring <robh+dt@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Jonathan Corbet <corbet@lwn.net>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, devicetree@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Alistair Popple <apopple@au1.ibm.com>

Balbir Singh <bsingharora@gmail.com> writes:
> On 09/08/16 04:27, Reza Arbab wrote:
>> Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>
>> ---
>>  .../bindings/powerpc/opal/hotplug-aperture.txt     | 26 ++++++++++++++++++++++
>>  1 file changed, 26 insertions(+)
>>  create mode 100644
>> Documentation/devicetree/bindings/powerpc/opal/hotplug-aperture.txt

Forgive me for being absent on the whole discussion here, but is this an
OPAL specific binding? If so, shouldn't the docs also appear in the
skiboot tree?

-- 
Stewart Smith
OPAL Architect, IBM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
