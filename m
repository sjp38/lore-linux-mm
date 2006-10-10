Message-ID: <452B5C54.6080704@tungstengraphics.com>
Date: Tue, 10 Oct 2006 10:39:48 +0200
From: Thomas Hellstrom <thomas@tungstengraphics.com>
MIME-Version: 1.0
Subject: Re: [patch 3/3] mm: fault handler to replace nopage and populate
References: <20061009110007.GA3592@wotan.suse.de>	 <1160392214.10229.19.camel@localhost.localdomain>	 <20061009111906.GA26824@wotan.suse.de>	 <1160393579.10229.24.camel@localhost.localdomain>	 <20061009114527.GB26824@wotan.suse.de>	 <1160394571.10229.27.camel@localhost.localdomain>	 <20061009115836.GC26824@wotan.suse.de>	 <1160395671.10229.35.camel@localhost.localdomain>	 <20061009121417.GA3785@wotan.suse.de>	 <452A50C2.9050409@tungstengraphics.com>	 <20061009135254.GA19784@wotan.suse.de>	 <1160427036.7752.13.camel@localhost.localdomain>	 <452B398C.4030507@tungstengraphics.com> <1160466932.6177.0.camel@localhost.localdomain>
In-Reply-To: <1160466932.6177.0.camel@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Benjamin Herrenschmidt wrote:
>>Still, even with NOPAGE_REFAULT or the equivalent with the new fault() code,
>>in the case we need to take this route, (and it looks like we won't have 
>>to),
>>I guess we still need to restart from find_vma() in the fault()/nopage() 
>>handler to make sure the VMA is still present. The object mutex need to 
>>be dropped as well to avoid deadlocks. Sounds complicated.
> 
> 
> But as we said, it should be enough to do the flag change with the
> object mutex held as long as it's after unmap_mapped_ranges()
> 
> Ben.
> 
> 
Agreed.
/Thomas



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
