Date: Tue, 29 Apr 2008 10:22:43 -0700
From: Greg KH <gregkh@suse.de>
Subject: Re: [RFC][PATCH] hugetlb: add information and interface in sysfs
	[Was Re: [RFC][PATCH 4/5] Documentation: add node files to sysfs
	ABI]
Message-ID: <20080429172243.GA16176@suse.de>
References: <20080422051447.GI21993@wotan.suse.de> <20080422165602.GA29570@us.ibm.com> <20080423010259.GA17572@wotan.suse.de> <20080423183252.GA10548@us.ibm.com> <20080424071352.GB14543@wotan.suse.de> <20080427034942.GB12129@us.ibm.com> <20080427051029.GA22858@suse.de> <20080428172239.GA24169@us.ibm.com> <20080428172951.GA764@suse.de> <20080429171115.GD24967@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080429171115.GD24967@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Nick Piggin <npiggin@suse.de>, Christoph Lameter <clameter@sgi.com>, wli@holomorphy.com, agl@us.ibm.com, luick@cray.com, Lee.Schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 29, 2008 at 10:11:15AM -0700, Nishanth Aravamudan wrote:
> +struct hstate_attribute {
> +	struct attribute attr;
> +	ssize_t (*show)(struct hstate *h, char *buf);
> +	ssize_t (*store)(struct hstate *h, const char *buf, size_t count);
> +};

Do you need your own attribute type with show and store?  Can't you just
use the "default" kobject attributes?

Also, you have no release function for your kobject to be cleaned up,
that's a major bug.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
