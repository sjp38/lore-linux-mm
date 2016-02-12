Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 738EE828DF
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 23:15:09 -0500 (EST)
Received: by mail-io0-f178.google.com with SMTP id l127so79847537iof.3
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 20:15:09 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id e4si1240673igl.84.2016.02.11.20.15.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Feb 2016 20:15:05 -0800 (PST)
Date: Fri, 12 Feb 2016 15:14:57 +1100
From: Paul Mackerras <paulus@ozlabs.org>
Subject: Re: [PATCH V2 00/29] Book3s abstraction in preparation for new MMU
 model
Message-ID: <20160212041457.GE13831@oak.ozlabs.ibm.com>
References: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Mon, Feb 08, 2016 at 02:50:12PM +0530, Aneesh Kumar K.V wrote:
> Hello,
> 
> This is a large series, mostly consisting of code movement. No new features
> are done in this series. The changes are done to accomodate the upcoming new memory
> model in future powerpc chips. The details of the new MMU model can be found at
> 
>  http://ibm.biz/power-isa3 (Needs registration). I am including a summary of the changes below.

This series doesn't seem to apply against either v4.4 or Linus'
current master.  What is this patch against?

Paul.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
