Date: Sun, 06 Apr 2003 09:13:04 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: objrmap and vmtruncate
Message-ID: <77670000.1049645582@[10.10.2.4]>
In-Reply-To: <1049640548.962.10.camel@dhcp22.swansea.linux.org.uk>
References: <20030404163154.77f19d9e.akpm@digeo.com> <12880000.1049508832@flay><20030405024414.GP16293@dualathlon.random> <20030404192401.03292293.akpm@digeo.com> <20030405040614.66511e1e.akpm@digeo.com>  <72740000.1049599406@[10.10.2.4]> <1049640548.962.10.camel@dhcp22.swansea.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Andrew Morton <akpm@digeo.com>, andrea@suse.de, mingo@elte.hu, hugh@veritas.com, dmccr@us.ibm.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> > 	14.91s user 75.30s system 24% cpu 6:15.84 total
>> 
>> Isn't the intent to use sys_remap_file_pages for these sort of workloads
>> anyway? In which case partial objrmap = rmap for these tests, so we're
>> still OK?
> 
> What matters is the worst case not the best case. Users will do non
> optimal things on a regular basis. 

Humpf. Well I have a fairly simple plan to fix it now. I'll either publish
some code or the plan later today, once I've thought about it a bit more.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
