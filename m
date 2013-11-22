Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id AE0BE6B0035
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 18:04:06 -0500 (EST)
Received: by mail-qc0-f169.google.com with SMTP id r5so1294835qcx.0
        for <linux-mm@kvack.org>; Fri, 22 Nov 2013 15:04:06 -0800 (PST)
Received: from mail-qa0-x231.google.com (mail-qa0-x231.google.com [2607:f8b0:400d:c00::231])
        by mx.google.com with ESMTPS id bk1si10835724qcb.112.2013.11.22.15.04.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 22 Nov 2013 15:04:04 -0800 (PST)
Received: by mail-qa0-f49.google.com with SMTP id ii20so4202805qab.1
        for <linux-mm@kvack.org>; Fri, 22 Nov 2013 15:04:04 -0800 (PST)
Date: Fri, 22 Nov 2013 18:04:00 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/3] percpu: stop the loop when a cpu belongs to a new
 group
Message-ID: <20131122230400.GG8981@mtj.dyndns.org>
References: <1382345893-6644-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <20131027123008.GJ14934@mtj.dyndns.org>
 <20131028030055.GC15642@weiyang.vnet.ibm.com>
 <20131028113120.GB11541@mtj.dyndns.org>
 <20131028151746.GA7548@weiyang.vnet.ibm.com>
 <20131120030056.GA15273@weiyang.vnet.ibm.com>
 <20131120055121.GA13754@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131120055121.GA13754@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <weiyang@linux.vnet.ibm.com>
Cc: cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello,

On Wed, Nov 20, 2013 at 12:51:21AM -0500, Tejun Heo wrote:
> The patch is just extremely marginal.  Ah well... why not?  I'll apply
> it once -rc1 drops.

So, I was about to apply this patch but decided against it.  It
doesn't really make anything better and the code looks worse
afterwards.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
