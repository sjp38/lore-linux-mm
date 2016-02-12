Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 42F446B0005
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 23:15:05 -0500 (EST)
Received: by mail-io0-f175.google.com with SMTP id l127so79846352iof.3
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 20:15:05 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id a194si17498238ioe.5.2016.02.11.20.15.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Feb 2016 20:15:04 -0800 (PST)
Date: Fri, 12 Feb 2016 14:53:34 +1100
From: Paul Mackerras <paulus@ozlabs.org>
Subject: Re: [PATCH V2 05/29] powerpc/mm: Copy pgalloc (part 2)
Message-ID: <20160212035334.GD13831@oak.ozlabs.ibm.com>
References: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1454923241-6681-6-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1454923241-6681-6-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Mon, Feb 08, 2016 at 02:50:17PM +0530, Aneesh Kumar K.V wrote:
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

This needs a proper patch description.

Paul.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
