From: "Abu M. Muttalib" <abum@aftek.com>
Subject: RE: Commenting out out_of_memory() function in __alloc_pages()
Date: Tue, 11 Jul 2006 20:27:07 +0530
Message-ID: <BKEKJNIHLJDCFGDBOHGMMEJLDCAA.abum@aftek.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <20060707095441.GA3913@lnx-holt.americas.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, nickpiggin@yahoo.com.au, Robert Hancock <hancockr@shaw.ca>, chase.venters@clientec.com, kernelnewbies@nl.linux.org, linux-newbie@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

The funniest part is that with memset commented out_of_memory observed,
contrary to my expectation.

I don't know why. It shouldn't have. I am running the application on an ARM
target.

Regards,
Abu.

-----Original Message-----
From: Robin Holt [mailto:holt@sgi.com]
Sent: Friday, July 07, 2006 3:25 PM
To: Abu M. Muttalib
Cc: kernelnewbies@nl.linux.org; linux-newbie@vger.kernel.org;
linux-kernel@vger.kernel.org; linux-mm
Subject: Re: Commenting out out_of_memory() function in __alloc_pages()


I am not sure about x86, but on ia64, you would be very hard pressed
for this application to actually run you out of memory.  With the
memset commented out, you would be allocating vmas, etc, but you
would not be actually putting pages behind those virtual addresses.

Thanks,
Robin

---------------------------  test1.c  ----------------------------------

#include<stdio.h>
#include<string.h>

main()
{
	char* buff;
	int count;

	count=0;
	while(1)
	{
		printf("\nOOM Test: Counter = %d", count);
		buff = (char*) malloc(1024);
	//	memset(buff,'\0',1024);
		count++;

		if (buff==NULL)
		{
			printf("\nOOM Test: Memory allocation error");
		}
	}
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
