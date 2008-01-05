Date: Sat, 5 Jan 2008 17:39:52 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: Fwd: comparion: solaris 10 vs RHEL5 - memory
Message-ID: <20080105173952.0b8db5f3@bree.surriel.com>
In-Reply-To: <6101e8c40801040821i495747f2ref1a0df711c23ea@mail.gmail.com>
References: <6101e8c40801040739i4d7f6e58rbd9b6d68e4565bc7@mail.gmail.com>
	<6101e8c40801040821i495747f2ref1a0df711c23ea@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Oliver Pinter (=?UTF-8?B?UGludMOpciBPbGl2w6ly?=)" <oliver.pntr@gmail.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 4 Jan 2008 17:21:39 +0100
"Oliver Pinter (PintA(C)r OlivA(C)r)"  <oliver.pntr@gmail.com> wrote:

> Maximum RAM:
> * 2 TB on current hardware  -> solaris10
> * 256 GB on X64 -> RHEL5

The amount listed for RHEL is not the theoretical maximum, but
the largest amount that has actually been tested. The limits are 
different per architecture.
 
> from http://blogs.sun.com/BVass/resource/SolarisRHELNEWcomparison.pdf
> 
> the questions is:
> 
> this informations is correct or not?

You'll also want to ask yourself the question:

	"Is this information complete?"

It's not hard to come up with a few checklist items where
RHEL looks better than Solaris, but they don't seem to be
in this particular PDF :)

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
