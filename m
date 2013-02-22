Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id D76536B000D
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 00:38:57 -0500 (EST)
Date: Fri, 22 Feb 2013 16:27:46 +1100
From: Paul Mackerras <paulus@samba.org>
Subject: Re: [RFC PATCH -V2 06/21] powerpc: Add size argument to
 pgtable_cache_add
Message-ID: <20130222052746.GF6139@drongo>
References: <1361465248-10867-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1361465248-10867-7-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1361465248-10867-7-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Thu, Feb 21, 2013 at 10:17:13PM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> We will use this later with THP changes. With THP we want to create PMD with
> twice the size. The second half will be used to depoist pgtable, which will
                                                  ^ deposit?
> carry the hpte hash index value

I'm not familiar with what "deposit" and "withdraw" mean in the THP
context.  If you can find a way to make the patch description more
informative for people who are not completely familiar with THP
(without adding a full-blown description of THP, of course) that would
be good.

Paul.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
