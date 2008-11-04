Message-ID: <491070B5.2060209@nortel.com>
Date: Tue, 04 Nov 2008 09:56:37 -0600
From: "Chris Friesen" <cfriesen@nortel.com>
MIME-Version: 1.0
Subject: Re: mmap: is default non-populating behavior stable?
References: <490F73CD.4010705@gmail.com> <1225752083.7803.1644.camel@twins> <490F8005.9020708@redhat.com>
In-Reply-To: <490F8005.9020708@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, "Eugene V. Lyubimkin" <jackyf.devel@gmail.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, hugh <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> Peter Zijlstra wrote:

>> The exact interaction of mmap() and truncate() I'm not exactly clear on.
> 
> Truncate will reduce the size of the mmaps on the file to
> match the new file size, so processes accessing beyond the
> end of file will get a segmentation fault (SIGSEGV).

I suspect Peter was talking about using truncate() to set the initial 
file size, effectively increasing rather than reducing it.

Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
