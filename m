Subject: Re: Why *not* rmap, anyway?
References: <Pine.LNX.4.44L.0204241112090.7447-100000@duckman.distro.conectiva>
From: Momchil Velikov <velco@fadata.bg>
Date: 24 Apr 2002 17:37:04 +0300
In-Reply-To: <Pine.LNX.4.44L.0204241112090.7447-100000@duckman.distro.conectiva>
Message-ID: <87k7qxuprj.fsf@fadata.bg>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Christian Smith <csmith@micromuse.com>, Joseph A Knapka <jknapka@earthlink.net>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "Rik" == Rik van Riel <riel@conectiva.com.br> writes:

Rik> On Wed, 24 Apr 2002, Christian Smith wrote:
>> On Tue, 23 Apr 2002, Rik van Riel wrote:
>> >On Tue, 23 Apr 2002, Christian Smith wrote:
>> >
>> >> The question becomes, how much work would it be to rip out the Linux MM
>> >> piece-meal, and replace it with an implementation of UVM?
>> >
>> >I doubt we want the Mach pmap layer.
>> 
>> Why not? It'd surely make porting to new architecures easier (not that
>> I've tried it either way, mind)

Rik> You really need to read the pmap code and interface instead
Rik> of repeating the statements made by other people. Have you
Rik> ever taken a close look at the overhead implicit in the pmap
Rik> layer ?

Actually, on ia32, there's no reason for the pmap layer to be any
different than the Linux radix tree. The overhead argument does not
stand.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
