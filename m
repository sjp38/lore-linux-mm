Subject: Re: Why *not* rmap, anyway?
References: <Pine.LNX.4.44L.0204241152100.7447-100000@duckman.distro.conectiva>
From: Momchil Velikov <velco@fadata.bg>
In-Reply-To: <Pine.LNX.4.44L.0204241152100.7447-100000@duckman.distro.conectiva>
Date: 24 Apr 2002 18:16:01 +0300
Message-ID: <873cxlunym.fsf@fadata.bg>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Christian Smith <csmith@micromuse.com>, Joseph A Knapka <jknapka@earthlink.net>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "Rik" == Rik van Riel <riel@conectiva.com.br> writes:

Rik> On 24 Apr 2002, Momchil Velikov wrote:
Rik> You really need to read the pmap code and interface instead
Rik> of repeating the statements made by other people. Have you
Rik> ever taken a close look at the overhead implicit in the pmap
Rik> layer ?
>> 
>> Actually, on ia32, there's no reason for the pmap layer to be any
>> different than the Linux radix tree. The overhead argument does not
>> stand.

Rik> So how do you run a pmap VM without duplicating the data from
Rik> the pmap layer into the page tables ?

Rik> Remember that for VM info the page tables -are- the radix tree.

And the page tables -are- the pmap layer :)

Regards,
-velco
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
