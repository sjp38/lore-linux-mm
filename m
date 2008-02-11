Date: Sun, 10 Feb 2008 21:48:35 -0500
From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: [PATCH 1/4] cpufreq: change cpu freq tables to per_cpu
	variables
Message-ID: <20080211024835.GD26696@codemonkey.org.uk>
References: <20080208233738.108449000@polaris-admin.engr.sgi.com> <20080208233738.292421000@polaris-admin.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080208233738.292421000@polaris-admin.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cpufreq@lists.linux.org.uk
List-ID: <linux-mm.kvack.org>

On Fri, Feb 08, 2008 at 03:37:39PM -0800, Mike Travis wrote:
 > Change cpu frequency tables from arrays to per_cpu variables.
 > 
 > Based on linux-2.6.git + x86.git

Looks ok to me.   Would you like me to push this though cpufreq.git,
or do you want the series to go through all in one?

	Dave

-- 
http://www.codemonkey.org.uk

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
