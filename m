Subject: Re: [PATCH] mhp: transfer dirty tag at radix_tree_replace
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20041005164627.GB3462@logos.cnet>
References: <20041001234200.GA4635@logos.cnet>
	 <20041002.183015.41630389.taka@valinux.co.jp>
	 <20041002183349.GA7986@logos.cnet>
	 <20041003.131338.41636688.taka@valinux.co.jp>
	 <20041005164627.GB3462@logos.cnet>
Content-Type: text/plain
Message-Id: <1097001326.30531.54.camel@localhost>
Mime-Version: 1.0
Date: Tue, 05 Oct 2004 11:35:26 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, iwamoto@valinux.co.jp, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2004-10-05 at 09:46, Marcelo Tosatti wrote:
> I still need to figure out how to use Iwamoto's patch to add/remove 
> zone's on the fly (for testing the migration process).

What I do (on my machine with 4G of RAM) is boot with mem=2G, then

	echo 0x8000000 > /sys/devices/system/memory/probe

which onlines 128MB more at 2GB.  Then, I allocate about 2GB of memory
with some app.  And this:
	
	echo offline > /sys/devices/system/memory/memory16/state

starts the migration process.  

Hirokazu, if you want to send me your latest patch set against the tree
that I just posted, I'll start to merge it up for real.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
