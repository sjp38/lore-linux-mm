Subject: Re: 2.5.63-mm2
From: Mark Wong <markw@osdl.org>
In-Reply-To: <20030304140918.4092f09b.akpm@digeo.com>
References: <20030302180959.3c9c437a.akpm@digeo.com>
	<1046815078.12931.79.camel@ibm-b>  <20030304140918.4092f09b.akpm@digeo.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 04 Mar 2003 15:06:24 -0800
Message-Id: <1046819184.12936.100.camel@ibm-b>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2003-03-04 at 14:09, Andrew Morton wrote:
> Mark Wong <markw@osdl.org> wrote:
> >
> > It appears something is conflicting with the old Adapatec AIC7xxx.  My
> > system halts when it attempts to probe the devices (I think it's that.) 
> > So I started using the new AIC7xxx driver and all is well.  I don't see
> > any messages to the console that points to any causes.  Is there
> > someplace I can look for a clue to the problem?
> > 
> > I actually didn't realize I was using the old driver and have no qualms
> > about not using it, but if it'll help someone else, I can help gather
> > information.
> 
> There are "fixes" in that driver in Linus's tree.  I suggest you revert to
> the 2.5.63 version of aic7xxx_old.c, see if that fixes it.

Reverting to Linus's 2.5.63 tree produces the same problem for me.  I
had thought I tried it before, but it turns out I was running 2.5.62. 
2.5.62's aic7xxx_old is good for me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
