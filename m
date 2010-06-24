From: Michal Marek <mmarek@suse.cz>
Subject: Re: [PATCH 31/40] trace syscalls: Convert various generic compat
 syscalls
Date: Thu, 24 Jun 2010 14:05:07 +0200
Message-ID: <4C2349F3.7090207__28389.3243795776$1284381161$gmane$org@suse.cz>
References: <1277287401-28571-1-git-send-email-imunsie@au1.ibm.com> <1277287401-28571-32-git-send-email-imunsie@au1.ibm.com> <4C21DFBA.2070202@linux.intel.com> <20100623102931.GB5242@nowhere> <4C21E3F8.9000405@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1Ov8D8-0003et-9a
	for glkm-linux-mm-2@m.gmane.org; Mon, 13 Sep 2010 14:32:38 +0200
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 233476B011F
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 08:31:47 -0400 (EDT)
In-Reply-To: <4C21E3F8.9000405@linux.intel.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linuxppc-dev@ozlabs.org, linux-fsdevel@vger.kernel.org, kexec@lists.infradead.org, netdev@vger.kernel.orglinuxppc-dev@ozlabs.orglinux-fsdevel@vger.kernel.orgkexec@lists.infradead.orgnetdev@vger.kernel.org
List-Id: linux-mm.kvack.org

On 23.6.2010 12:37, Andi Kleen wrote:
> It also has maintenance costs, e.g. I doubt ctags and cscope
> will be able to deal with these kinds of macros, so it has a
> high cost for everyone using these tools.

FWIW, patch 16/40 of this series teaches 'make tags' to recognize these
macros: http://permalink.gmane.org/gmane.linux.kernel/1002103

Michal

--
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
