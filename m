Message-ID: <44986056.5040300@google.com>
Date: Tue, 20 Jun 2006 13:53:42 -0700
From: Martin Bligh <mbligh@google.com>
MIME-Version: 1.0
Subject: Re: zoned-vm-stats-add-nr_anon.patch
References: <44985E9E.1070603@google.com> <Pine.LNX.4.64.0606201347470.12229@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0606201347470.12229@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Tue, 20 Jun 2006, Martin Bligh wrote:
> 
> 
>>Could we rename nr_mapped to something else if we're going to change
>>it's meaning? Perhaps split nr_mapped into nr_mapped_file and
>>nr_mapped_anon or something?
> 
> 
> Yes we did that. nr_mapped was split into NR_MAPPED and NR_ANON. Please 
> read the description for V4 if this patchset that was posted last week.

Yeah, but ... that's what I'm concerned about, the naming of it.
Splitting it makes sense, just needs to be renamed something else, I think.

>>In my mind, "nr_mapped" is a good name for the number of pages which
>>are mapped, so excluding the anon pages from that seems to make
>>the naming non-obvious. similarly, I presume we can have anon pages
>>on transition to or from swap that are not mapped, and yet will
>>not be reflected here, so nr_anon doesn't seem like a wholly
> 
> The same confusion exist for nr_dirty. Should we also rename nr_dirty to 
> nr_dirty_file?

Sure. Naming is important, IMHO. People reading code make involuntary
assumptions as they read code, it's inevitable.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
