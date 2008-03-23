Date: Sun, 23 Mar 2008 20:30:31 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] [2/18] Add basic support for more than one hstate in hugetlbfs
In-Reply-To: <20080323112829.GA1619@one.firstfloor.org>
References: <20080323193340.B31D.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080323112829.GA1619@one.firstfloor.org>
Message-Id: <20080323203010.B323.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, pj@sgi.com, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

> > this function is called once by one boot parameter, right?
> > if so, this function cause panic when stupid user write many 
> > hugepagesz boot parameter.
> 
> A later patch fixes that up by looking up the hstate explicitely. Also it 
> is bisect safe because the callers are only added later.

Oops, sorry.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
