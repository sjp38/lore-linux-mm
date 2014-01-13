Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id DAB2B6B0035
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 08:37:51 -0500 (EST)
Received: by mail-ie0-f169.google.com with SMTP id at1so255783iec.0
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 05:37:51 -0800 (PST)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id ku5si17898967igb.3.2014.01.13.05.37.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 13 Jan 2014 05:37:50 -0800 (PST)
Message-ID: <1389620262.4672.130.camel@pasglop>
Subject: Re: [PATCH V4] powerpc: thp: Fix crash on mremap
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Tue, 14 Jan 2014 00:37:42 +1100
In-Reply-To: <87wqi42p0f.fsf@linux.vnet.ibm.com>
References: 
	<1389593064-32664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	 <1389598587.4672.121.camel@pasglop> <87wqi42p0f.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: aarcange@redhat.com, paulus@samba.org, kirill.shutemov@linux.intel.com, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Mon, 2014-01-13 at 15:16 +0530, Aneesh Kumar K.V wrote:
> Benjamin Herrenschmidt <benh@kernel.crashing.org> writes:
> 
> > On Mon, 2014-01-13 at 11:34 +0530, Aneesh Kumar K.V wrote:
> >> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> >> 
> >> This patch fix the below crash
> >
> > Andrea, can you ack the generic bit please ?
> >
> > Thanks !
> 
> Kirill A. Shutemov did ack an earlier version
> 
> http://article.gmane.org/gmane.linux.kernel.mm/111368

Doesn't help. If I'm going to send Linus a patch with a generic change
like that, I need an ack of that exact version of the change by a senior
mm person such as Andrea.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
