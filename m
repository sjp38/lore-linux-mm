Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A03756B00C4
	for <linux-mm@kvack.org>; Fri,  2 Jan 2009 13:09:49 -0500 (EST)
Subject: Re: [PATCH] Update of Documentation/
From: "Peter W. Morreale" <pmorreale@novell.com>
In-Reply-To: <20090102180412.3676.27341.stgit@hermosa.site>
References: <20090102180412.3676.27341.stgit@hermosa.site>
Content-Type: text/plain
Date: Fri, 02 Jan 2009 11:09:43 -0700
Message-Id: <1230919783.3470.247.camel@hermosa.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: randy.dunlap@oracle.com
Cc: linux-kernel@vger.kernel.org, riel@nl.linux.org, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, 2009-01-02 at 11:04 -0700, Peter W Morreale wrote:
> This patch updates Documentation/sysctl/vm.txt and
> Documentation/filesystems/proc.txt.   More specifically, the section on
> /proc/sys/vm in Documentation/filesystems/proc.txt was removed and a
> link to Documentation/sysctl/vm.txt added.
> 
> Most of the verbiage from proc.txt was simply moved in vm.txt, with new
> addtional text for "swappiness" and "stat_interval".
> 
> This update reflects the current state of 2.6.27.
> 
> Best,
> -PWM
> ---

Crud.  Best laid plans and all that...  

I forgot to mention that this version incorporates Randy's suggestion
about omitting the potential new sysctls for pdflush. 

I will respin the pdflush patches against this patch so the
Documentation hunk will apply.

Thx,
-PWM

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
