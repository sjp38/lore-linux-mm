Date: Tue, 25 Mar 2008 22:15:54 -0400
From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: [PATCH 04/12] cpumask: pass cpumask by reference to
	acpi-cpufreq
Message-ID: <20080326021554.GA8388@codemonkey.org.uk>
References: <20080326013811.569646000@polaris-admin.engr.sgi.com> <20080326013812.324977000@polaris-admin.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080326013812.324977000@polaris-admin.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Len Brown <len.brown@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, Mar 25, 2008 at 06:38:15PM -0700, Mike Travis wrote:
 > Pass cpumask_t variables by reference in acpi-cpufreq functions.
 > 
 > Based on:
 > 	git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
 > 	git://git.kernel.org/pub/scm/linux/kernel/git/x86/linux-2.6-x86.git
 > 
 > Cc: Len Brown <len.brown@intel.com>
 > Cc: Dave Jones <davej@codemonkey.org.uk>
 > Signed-off-by: Mike Travis <travis@sgi.com>

As this is dependant on non-cpufreq bits, I'm assuming this is going
via Ingo.  From a quick eyeball of this, and the change its dependant on,
it looks ok to me.

	Dave

-- 
http://www.codemonkey.org.uk

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
