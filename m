Message-ID: <4254842C.60306@engr.sgi.com>
Date: Wed, 06 Apr 2005 19:51:56 -0500
From: Ray Bryant <raybry@engr.sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH_FOR_REVIEW 2.6.12-rc1 2/3] mm: manual page	migration-rc1
 -- add node_map arg to try_to_migrate_pages()
References: <20050406041633.25060.64831.21849@jackhammer.engr.sgi.com>	 <20050406041701.25060.91114.75958@jackhammer.engr.sgi.com> <1112801963.19430.151.camel@localhost>
In-Reply-To: <1112801963.19430.151.camel@localhost>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Ray Bryant <raybry@sgi.com>, Hirokazu Takahashi <taka@valinux.co.jp>, Andi Kleen <ak@suse.de>, Marcello Tosatti <marcello@cyclades.com>, Ray Bryant <raybry@austin.rr.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> On Tue, 2005-04-05 at 21:17 -0700, Ray Bryant wrote:
> 
>>+#ifdef CONFIG_NUMA
>>+static inline struct page *node_migrate_onepage(struct page *page, short *node_map) 
>>+{
>>+	if (node_map)
>>+		return migrate_onepage(page, node_map[page_to_nid(page)]);
>>+	else
>>+		return migrate_onepage(page, MIGRATE_NODE_ANY); 
>>+		
>>+}
>>+#else
>>+static inline struct page *node_migrate_onepage(struct page *page, short *node_map) 
>>+{
>>+	return migrate_onepage(page, MIGRATE_NODE_ANY); 
>>+}
>>+#endif
> 
> 
> I don't think that #ifdef is needed.  A user is always welcome to call
> node_migrate_onepage() with a non-existent node in node_map[] because
> they'll just get an error when the allocation attempt occurs.  The same
> is true when there's only one node.  
> 
> -- Dave
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
> 
Sounds reasonable to me.

-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
