Date: Fri, 12 Mar 2004 23:39:00 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Poor DBT-3 pgsql 8way numbers on recent 2.6 mm kernels
Message-Id: <20040312233900.0d68711e.akpm@osdl.org>
In-Reply-To: <1079130684.2961.134.camel@localhost>
References: <1079130684.2961.134.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: maryedie@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mary Edie Meredith <maryedie@osdl.org> wrote:
>
> For the last few mm kernels, I have discovered a
>  performance problem in DBT-3 (using PostgreSQL) 
>  in the "throughput" portion of the test (when the
>  test is running multiple processes ) on our 8-way
>  STP systems as compared to 4-way runs and the baseline
>  kernel results.

If I could reproduce this I could find and fix it very quickly.  But when I
tried to get dbt2 working it was a near-death (and unsuccessful)
experience.  Did it get any easier in dbt3?

I wold be suspecting the darn readahead code again.  That was merged into
Linus's tree yesterday so perhaps you can test latest -bk?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
