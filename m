Date: Fri, 15 Aug 2008 11:33:50 +0200
From: Jean Delvare <khali@linux-fr.org>
Subject: Re: kernel BUG at arch/x86/mm/pat.c:233 in 2.6.27-rc3-git2
Message-ID: <20080815113350.538d0ba8@hyperion.delvare>
In-Reply-To: <9D39833986E69849A2A8E74C1078B6B3D7A7CD@orsmsx415.amr.corp.intel.com>
References: <20080814161852.2dce7c21@hyperion.delvare>
	<9D39833986E69849A2A8E74C1078B6B3D7A7CD@orsmsx415.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Moore, Robert" <robert.moore@intel.com>
Cc: linux-mm@kvack.org, linux-acpi@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, lenb@kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 14 Aug 2008 12:59:45 -0700, Moore, Robert wrote:
> Please open a bugzilla and attach the acpidump for the machine.

Done:
http://bugzilla.kernel.org/show_bug.cgi?id=11346

I've rebuilt the kernel with CONFIG_FRAME_POINTER=y as requested by
Andi. I've also attached the kernel config and the output of dmesg for
the last working kernel. If anything else is needed, just ask.

-- 
Jean Delvare

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
