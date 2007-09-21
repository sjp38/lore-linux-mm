Date: Fri, 21 Sep 2007 02:12:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 0/9] oom killer serialization
Message-Id: <20070921021208.e6fec547.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.0.9999.0709201318090.25753@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709201318090.25753@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Christoph Lameter <clameter@sgi.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 20 Sep 2007 13:23:13 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> Third version of the OOM serialization patchset. 

What's the relationship between this patch series and Andrea's monster
oomkiller patchset?  Looks like teeny-subset-plus-other-stuff?

Are all attributions on all those patches appropriately set?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
