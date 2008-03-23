Date: Sun, 23 Mar 2008 12:28:29 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [2/18] Add basic support for more than one hstate in hugetlbfs
Message-ID: <20080323112829.GA1619@one.firstfloor.org>
References: <20080317258.659191058@firstfloor.org> <20080317015815.D43991B41E0@basil.firstfloor.org> <20080323193340.B31D.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080323193340.B31D.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, pj@sgi.com, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

> this function is called once by one boot parameter, right?
> if so, this function cause panic when stupid user write many 
> hugepagesz boot parameter.

A later patch fixes that up by looking up the hstate explicitely. Also it 
is bisect safe because the callers are only added later.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
