Message-ID: <46EEC978.9080303@sgi.com>
Date: Mon, 17 Sep 2007 11:37:44 -0700
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/6] cpuset write dirty map
References: <469D3342.3080405@google.com> <46E741B1.4030100@google.com>	 <46E742A2.9040006@google.com>	 <20070914161536.3ec5c533.akpm@linux-foundation.org>	 <a781481a0709141647q3d019423s388c64bf6bed871a@mail.gmail.com>	 <20070914170733.dbe89493.akpm@linux-foundation.org> <a781481a0709141716n569d54eeqbe51746d3a5110ca@mail.gmail.com>
In-Reply-To: <a781481a0709141716n569d54eeqbe51746d3a5110ca@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Satyam Sharma <satyam.sharma@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ethan Solomita <solo@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Satyam Sharma wrote:
 > True, the other option could be to put the /pointer/ in there unconditionally,
> but that would slow down the MAX_NUMNODES <= BITS_PER_LONG case,
> which (after grepping through defconfigs) appears to be the common case on
> all archs other than ia64. So I think your idea of making that conditional
> centralized in the code with an accompanying comment is the way to go here ...

It won't be long before arch's other than ia64 will have
MAX_NUMNODES > BITS_PER_LONG. While it won't be the norm,
we should account for it now.

Thanks,
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
