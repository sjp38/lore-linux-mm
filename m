Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 333F46B006C
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 07:05:08 -0400 (EDT)
Received: by dakp5 with SMTP id p5so8876188dak.14
        for <linux-mm@kvack.org>; Mon, 02 Jul 2012 04:05:07 -0700 (PDT)
Date: Mon, 2 Jul 2012 04:05:04 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v3 3/3] mm/sparse: more check on mem_section number
In-Reply-To: <1341221337-4826-3-git-send-email-shangw@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.00.1207020404380.14758@chino.kir.corp.google.com>
References: <1341221337-4826-1-git-send-email-shangw@linux.vnet.ibm.com> <1341221337-4826-3-git-send-email-shangw@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, dave@linux.vnet.ibm.com, mhocko@suse.cz, akpm@linux-foundation.org

On Mon, 2 Jul 2012, Gavin Shan wrote:

> Function __section_nr() was implemented to retrieve the corresponding
> memory section number according to its descriptor. It's possible that
> the specified memory section descriptor isn't existing in the global
> array. So here to add more check on that and report error for wrong
> case.
> 
> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
