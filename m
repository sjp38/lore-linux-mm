Subject: Re: 2.5.68-mm4
From: Steven Cole <elenstev@mesatop.com>
In-Reply-To: <20030502020149.1ec3e54f.akpm@digeo.com>
References: <20030502020149.1ec3e54f.akpm@digeo.com>
Content-Type: text/plain
Message-Id: <1051886748.2166.20.camel@spc9.esa.lanl.gov>
Mime-Version: 1.0
Date: 02 May 2003 08:45:48 -0600
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2003-05-02 at 03:01, Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.68/2.5.68-mm4/
> 
> . Much reworking of the disk IO scheduler patches due to the updated
>   dynamic-disk-request-allocation patch.  No real functional changes here.
> 
> . Included the `kexec' patch - load Linux from Linux.  Various people want
>   this for various reasons.  I like the idea of going from a login prompt to
>   "Calibrating delay loop" in 0.5 seconds.
> 
>   I tried it on four machines and it worked with small glitches on three of
>   them, and wedged up the fourth.  So if it is to proceed this code needs
>   help with testing and careful bug reporting please.
> 
>   There's a femto-HOWTO in the patch itself, reproduced here:
> 
> 
> 
> - enable kexec in config, build, install.
> 
> - grab kexec-tools from
> 
> 	http://www.osdl.org/archive/andyp/kexec/2.5.68/
> 
The andyp directory seems to be missing.  I found kexec-tools-1.8 here:
http://www.xmission.com/~ebiederm/files/kexec/

Is that the latest version?

Steven

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
