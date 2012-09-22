Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id C0C7B6B0044
	for <linux-mm@kvack.org>; Sat, 22 Sep 2012 09:31:41 -0400 (EDT)
Received: by eekc4 with SMTP id c4so626026eek.14
        for <linux-mm@kvack.org>; Sat, 22 Sep 2012 06:31:40 -0700 (PDT)
Message-ID: <505DBDC5.3010503@gmail.com>
Date: Sat, 22 Sep 2012 15:31:49 +0200
From: Sasha Levin <levinsasha928@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC] mm: add support for zsmalloc and zcache
References: <1346794486-12107-1-git-send-email-sjenning@linux.vnet.ibm.com> <20120921161252.GV11266@suse.de> <15c1d12a-0e29-478f-97e0-ee4063e2cba5@default>
In-Reply-To: <15c1d12a-0e29-478f-97e0-ee4063e2cba5@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Mel Gorman <mgorman@suse.de>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 09/21/2012 09:14 PM, Dan Magenheimer wrote:
>>> +#define MAX_CLIENTS 16
>> > 
>> > Seems a bit arbitrary. Why 16?
> Sasha Levin posted a patch to fix this but it was tied in to
> the proposed KVM implementation, so was never merged.
> 

My patch changed the max pools per client, not the maximum amount of clients.
That patch has already found it's way in.

(MAX_CLIENTS does look like an arbitrary number though).


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
