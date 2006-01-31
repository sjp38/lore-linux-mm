Date: Tue, 31 Jan 2006 13:18:37 -0600
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: [PATCH/RFC] Shared page tables
Message-ID: <15D75E814ADD9E4E6FCCD9E1@[10.1.1.4]>
In-Reply-To: <43DFB0D7.3070805@us.ibm.com>
References: <A6D73CCDC544257F3D97F143@[10.1.1.4]>
 <Pine.LNX.4.61.0601202020001.8821@goblin.wat.veritas.com>
 <43DAA3C9.9070105@us.ibm.com> <200601301246.27455.raybry@mpdtxmail.amd.com>
 <43DFB0D7.3070805@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Brian Twichell <tbrian@us.ibm.com>, Ray Bryant <raybry@mpdtxmail.amd.com>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--On Tuesday, January 31, 2006 12:47:51 -0600 Brian Twichell
<tbrian@us.ibm.com> wrote:

>> Do you know if Dave's patch supports sharing of pte's for 2 MB pages on 
>> X86_64?
>>  
>> 
> I believe it does.  Dave, can you confirm ?

It shares pmd pages for hugepages, which I assume is what you're talking
about.

Dave McCracken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
