From: Michal Marek <mmarek@suse.cz>
Subject: Re: [PATCH 31/40] trace syscalls: Convert various generic compat
 syscalls
Date: Thu, 24 Jun 2010 14:05:07 +0200
Message-ID: <4C2349F3.7090207__25301.649401854$1277381425$gmane$org@suse.cz>
References: <1277287401-28571-1-git-send-email-imunsie@au1.ibm.com> <1277287401-28571-32-git-send-email-imunsie@au1.ibm.com> <4C21DFBA.2070202@linux.intel.com> <20100623102931.GB5242@nowhere> <4C21E3F8.9000405@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1ORlG9-000396-5S
	for glkm-linux-mm-2@m.gmane.org; Thu, 24 Jun 2010 14:10:21 +0200
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 834986B0071
	for <linux-mm@kvack.org>; Thu, 24 Jun 2010 08:10:16 -0400 (EDT)
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1ORlFr-0002zq-4f
	for linux-mm@kvack.org; Thu, 24 Jun 2010 14:10:03 +0200
Received: from nat.scz.novell.com ([213.151.88.252])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Thu, 24 Jun 2010 14:10:03 +0200
Received: from mmarek by nat.scz.novell.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Thu, 24 Jun 2010 14:10:03 +0200
In-Reply-To: <4C21E3F8.9000405@linux.intel.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, linux-fsdevel@vger.kernel.org, kexec@lists.infradead.org, netdev@vger.kernel.org
List-Id: linux-mm.kvack.org

On 23.6.2010 12:37, Andi Kleen wrote:
> It also has maintenance costs, e.g. I doubt ctags and cscope
> will be able to deal with these kinds of macros, so it has a
> high cost for everyone using these tools.

FWIW, patch 16/40 of this series teaches 'make tags' to recognize these
macros: http://permalink.gmane.org/gmane.linux.kernel/1002103

Michal

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
