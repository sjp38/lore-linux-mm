Date: Mon, 26 Sep 2005 23:29:01 +0100
From: Alex Bligh - linux-kernel <linux-kernel@alex.org.uk>
Reply-To: Alex Bligh - linux-kernel <linux-kernel@alex.org.uk>
Subject: Re: [PATCH 4/9] defrag helper functions
Message-ID: <C50046EE58FA62242E92877C@[192.168.100.25]>
In-Reply-To: <43385594.3080303@austin.ibm.com>
References: <4338537E.8070603@austin.ibm.com>
 <43385594.3080303@austin.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Joel Schopp <jschopp@austin.ibm.com>, Andrew Morton <akpm@osdl.org>
Cc: lhms <lhms-devel@lists.sourceforge.net>, Linux Memory Management List <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Mike Kravetz <kravetz@us.ibm.com>, Alex Bligh - linux-kernel <linux-kernel@alex.org.uk>
List-ID: <linux-mm.kvack.org>


--On 26 September 2005 15:09 -0500 Joel Schopp <jschopp@austin.ibm.com> 
wrote:

> +void assign_bit(int bit_nr, unsigned long* map, int value)

Maybe:
static inline void assign_bit(int bit_nr, unsigned long* map, int value)

it's short enough

>  +static struct page *
> +fallback_alloc(int alloctype, struct zone *zone, unsigned int order)
> +{
> +       /* Stub out for seperate review, NULL equates to no fallback*/
> +       return NULL;
> +
> +}

Maybe "static inline" too.

--
Alex Bligh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
