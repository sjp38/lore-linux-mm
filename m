Date: Tue, 12 Oct 2004 07:26:32 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [RFC] memory defragmentation to satisfy high order allocations
Message-ID: <1509480000.1097591191@[10.10.2.4]>
In-Reply-To: <20041012105657.D1D0670463@sv1.valinux.co.jp>
References: <20041008100010.GB16028@logos.cnet><20041008.212319.19886370.taka@valinux.co.jp><20041008124149.GI16028@logos.cnet><20041009.015239.74741436.taka@valinux.co.jp><20041008153646.GJ16028@logos.cnet> <20041012105657.D1D0670463@sv1.valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: IWAMOTO Toshihiro <iwamoto@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, haveblue@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> > iwamoto> I don't think requiring swap is a big deal.  If you don't have a
>> > iwamoto> dedicated swap device, which case I think unusual, you can swapon a
>> > iwamoto> regular file.
>> 
>> Sure its not a big deal, but nicer if it doesnt require swap.
> 
>> For memory defragmentation it is a big deal.
> 
> Why?  IMO, it isn't very rewarding to tune memory
> migration/defragmentation performance as they involve memory copy
> anyway.
> 
> Or, do you want memory defragmentation everywhere, including embedded
> systems?

Lots of systems nowadays don't have swap configured, not just embedded.
What do we gain from making defrag slower and harder to use, by forcing
it to use swap? Isn't pushing it into the swapcache sufficient?

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
