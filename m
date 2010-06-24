From: Michal Marek <mmarek@suse.cz>
Subject: Re: [PATCH 31/40] trace syscalls: Convert various generic compat
 syscalls
Date: Thu, 24 Jun 2010 14:05:07 +0200
Message-ID: <4C2349F3.7090207__41715.0461617441$1277382317$gmane$org@suse.cz>
References: <1277287401-28571-1-git-send-email-imunsie@au1.ibm.com> <1277287401-28571-32-git-send-email-imunsie@au1.ibm.com> <4C21DFBA.2070202@linux.intel.com> <20100623102931.GB5242@nowhere> <4C21E3F8.9000405@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <4C21E3F8.9000405@linux.intel.com>
Sender: linux-fsdevel-owner@vger.kernel.org
To: linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, kexec@lists.infradead.org, netdev@vger.kernel.orglinux-mm@kvack.orglinux-kernel@vger.kernel.orgkexec@lists.infradead.orgnetdev@vger.kernel.orglinux-kernel@vger.kernel.orglinuxppc-dev@ozlabs.orgkexec@lists.infradead.orgnetdev@vger.kernel.org
List-Id: linux-mm.kvack.org

On 23.6.2010 12:37, Andi Kleen wrote:
> It also has maintenance costs, e.g. I doubt ctags and cscope
> will be able to deal with these kinds of macros, so it has a
> high cost for everyone using these tools.

FWIW, patch 16/40 of this series teaches 'make tags' to recognize these
macros: http://permalink.gmane.org/gmane.linux.kernel/1002103

Michal

